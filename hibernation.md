# Hibernation

## What went wrong (2026-09-02)

The laptop ran out of battery and powered off instead of hibernating, losing a
22-day session. The configs were all correct; hibernation was simply
*unavailable*, and every path degraded silently.

    Sep 02 13:27:46 systemd-logind[685]: The system will power off now!

## Mechanism

systemd refuses hibernation unless

    Active(anon) <= (SwapTotal - SwapUsed) * 0.98

and it checks **one** swap area -- the entry in `/proc/swaps` matching
`/sys/power/resume`, which the initramfs sets from the `resume=` kernel
parameter. It does not sum swap areas, and it does not pick the largest.

With 23 GiB RAM and a 24 GiB swap LV there is ~20 GiB of headroom on a fresh
boot, and none after a long session: `Active(anon)` grows while used swap
shrinks the free pool, squeezing the margin from both sides.

Once the check fails, nothing says so plainly:

- `HandleLidSwitch` / `IdleAction=suspend-then-hibernate` -> plain suspend,
  logged as `Requested suspend-then-hibernate operation is not supported`
- UPower `CriticalPowerAction=HybridSleep` -> falls through
  HybridSleep -> Hibernate -> **PowerOff**, logging nothing about the fallback

The machine still *sleeps* normally, so the failure is invisible until the
battery actually runs out. It had been broken for weeks: hibernation last
worked 2026-08-26, with hundreds of refusals after that.

## Diagnosing

    # has it degraded? (silence = healthy; check after days of uptime,
    # a fresh boot always passes)
    journalctl -b0 | grep "operation is not supported"

    # what does systemd actually decide, and against which swap area?
    sudo systemctl service-log-level systemd-logind debug
    busctl call org.freedesktop.login1 /org/freedesktop/login1 \
      org.freedesktop.login1.Manager CanHibernate
    journalctl -b0 -u systemd-logind --since -20s | grep Detected
    sudo systemctl service-log-level systemd-logind info

The `Detected ... swap for hibernation:` line prints `Active(anon)`, and the
`size`/`used` of the area it chose. Confirm `size` is the area you expect.

## Fix on a NEW machine

Size the swap LV at >= 2x RAM at install time. `install.sh` does this (see README step 1).
`resume=/dev/Group/swap` then stays correct and nothing else is needed.

## Remediation on an EXISTING machine

When repartitioning is too expensive -- shrinking a large ext4 root offline can
run for hours -- add a swapfile and point `resume=` at it instead.

    fallocate -l 40G /swapfile && chmod 600 /swapfile
    mkswap /swapfile && swapon /swapfile
    echo '/swapfile none swap defaults 0 0' >> /etc/fstab

    # physical block of the swapfile; fs block size and page size are both 4096
    filefrag -v /swapfile | awk '/^ *0:/{gsub(/\.\./,"",$4); print $4; exit}'

Then repoint `resume=` at the filesystem holding it, keeping the old entry as a
fallback (this machine boots EFISTUB, so the cmdline lives in the UEFI boot
entry, not a bootloader config):

    efibootmgr --create --disk /dev/nvme0n1 --part 2 \
      --label "Arch Linux (swapfile resume)" --loader '\vmlinuz-linux' \
      --unicode 'cryptdevice=UUID=...:root:allow-discards root=/dev/Group/root resume=/dev/Group/root resume_offset=<N> initrd=\intel-ucode.img rw initrd=\initramfs-linux.img'

No `mkinitcpio -P` needed: the `resume` hook defers to
`systemd-hibernate-resume`, which is already in the initramfs and understands
`resume_offset`. The `encrypt` and `lvm2` hooks run before `resume`, so the LV
exists in time, and `resume` runs before root is mounted rw.

**Caveat:** `resume_offset` is a physical block number. If the swapfile is
deleted and recreated, relocated by `e2fsck`, or defragmented, it goes stale.
That fails safe -- no hibernation signature is found and the machine boots
normally -- but hibernation is silently lost again, so re-run `filefrag` and
update the boot entry if that file is ever touched. This fragility is why a
correctly sized swap LV is preferred on a new build.

**Switching the resume device is a two-sided change (2026-09-05 incident).**
The running kernel writes the hibernation image to whatever `/sys/power/resume`
and `/sys/power/resume_offset` say *right now*; the next boot reads from
whatever `resume=` on its cmdline says. `systemd-hibernate-resume` prefers the
cmdline over the `HibernateLocation` EFI variable ("doesn't match with EFI
HibernateLocation device, proceeding anyway with resume="), so the EFI variable
does not rescue a mismatch. If the two disagree, the next boot finds no image,
starts fresh, and `swapon` on the old device then prints "software suspend
data detected. Rewriting the swap signature" -- the session is gone.

This is exactly what happened: the new boot entry was made default while the
running kernel still pointed at the partition; the laptop hibernated overnight
to the partition; the morning boot used the new entry, looked in the swapfile,
and wiped the partition image. After creating the new entry, do ONE of:

    # (a) repoint the running kernel too, so both sides agree immediately
    echo <N>   | sudo tee /sys/power/resume_offset
    echo 253:2 | sudo tee /sys/power/resume     # major:minor of the fs holding /swapfile

    # (b) reboot right away, before any lid-close or idle timeout can fire

And if a boot ever comes up fresh when it should have resumed, pick the OLD
boot entry from the firmware menu *before* the OS starts -- once `swapon`
has run, the image is unrecoverable.

## Verify, don't assume

Hibernation always looks fine right after a boot. Test it for real, with
nothing important open:

    sudo systemctl hibernate

Power back on and confirm the session returned.
