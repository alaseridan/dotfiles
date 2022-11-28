#### The commands may not run until after the env has been refreshed, it is best to restart powershell then run these ####

#--- Install python packages ---#
pip install --upgrade pip
pip install backoff
pip install boto3
pip install jedi-language-server
pip install msal
pip install mypy
pip install opencv-python
pip install pipdeptree
pip install pylint
pip install pynvim
pip install pytest-mock
pip install structlog

#--- Install vs code plugins ---#
code --install-extension AdamRybak.graycat-sql-formatter
code --install-extension asvetliakov.vscode-neovim
code --install-extension eamodio.gitlens
code --install-extension firsttris.vscode-jest-runner
code --install-extension ms-dotnettools.csharp
code --install-extension ms-mssql.data-workspace-vscode
code --install-extension ms-mssql.mssql
code --install-extension ms-mssql.sql-database-projects-vscode
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension octref.vetur
code --install-extension redhat.java
code --install-extension VisualStudioExptTeam.vscodeintellicode
code --install-extension vscjava.vscode-java-debug
code --install-extension vscjava.vscode-java-dependency
code --install-extension vscjava.vscode-java-pack
code --install-extension vscjava.vscode-java-test
code --install-extension vscjava.vscode-maven
code --install-extension VSpaceCode.whichkey

#config git to get with the times and allow long file names
git config --global core.longpaths true
