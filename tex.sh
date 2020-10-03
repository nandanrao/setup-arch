# fix tlmgr as per arch documentation. 

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

