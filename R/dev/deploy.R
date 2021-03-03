library(rsconnect)

rsconnect::setAccountInfo(name='labsyspharm',
                          token='DAC9767482D081D508CAD4F56E9CE22D',
                          secret='b6lTwrSYUz+sY/k9JCkygNqlCc+6UNQE11c3qGaF')
applications("labsyspharm")

#rsconnect::deployApp(appName = "smallmoleculesuite-dev", appTitle = "Small Molecule Suite - Development version", account = "labsyspharm")

rsconnect::deployApp(appName = "smallmoleculesuite", appTitle = "Small Molecule Suite", account = "labsyspharm")

rsconnect::configureApp(appName = "smallmoleculesuite", account = "labsyspharm", size = "xxlarge")
#

