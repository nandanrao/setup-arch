
# CURRENT:
# Install TexLive manually, without Pacman
# https://wiki.archlinux.org/index.php/TeX_Live
# no setup after that? Maybe tlmgr staid from old install? 

# OLD: with Arch/pacman
# First: fix tlmgr.pl as per arch documentation. 
tlmgr init-usertree 
tlmgr option repository http://ctan.crest.fr/tex-archive/systems/texlive/tlnet 

tlmgr install \
      enumitem \
      appendixnumberbeamer \
      ccicons \
      pgfplots \
      xstring \
      tcilatex \
      pgfopts \
      pgf \
      textpos \
      libertine \
      fontaxes \
      mweights \
      roboto \
      beamertheme-metropolis \

