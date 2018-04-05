..\.nuget\NuGet.exe restore ..\.nuget\packages.config -PackagesDirectory .\packages\
.\packages\FAKE.4.37.2\tools\FAKE.exe fake.fsx target="BuildPackForDeploy"