# escape=`

# Use the latest jenkins agent Windows Server Core image with jdk11.
FROM jenkins/inbound-agent:jdk11-windowsservercore-ltsc2019

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/17/release/vs_Enterprise.exe C:\\TEMP\\vs_Enterprise.exe

# Install Visual Studio workloads. https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-enterprise
RUN C:\\TEMP\\vs_Enterprise.exe --quiet --wait --norestart --nocache `
    --add Microsoft.VisualStudio.Workload.ManagedDesktop `
    --add Microsoft.VisualStudio.Workload.CoreEditor `
    --add Microsoft.VisualStudio.Workload.NetWeb;includeRecommended;includeOptional `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

#Additional tool to convert code coverage to xml
RUN powershell.exe dotnet tool install --global dotnet-coverage

# EDIT WITH CAUTION!!!!! PATH for MSBuild Powershell. Do not use setx because it will truncate. Strings below are delicate!!! I have no idea why the Visual Studio install does not take care of this
RUN powershell.exe [Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\Extensions\TestPlatform;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Team Tools\Dynamic Code Coverage Tools;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\VC\Linux\bin\ConnectionManagerExe;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\;C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\FSharp\;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\Extensions\Microsoft\IntelliCode\CLI;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\VC\VCPackages;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\bin\Roslyn;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Team Tools\Performance Tools;C:\Program Files (x86)\Microsoft Visual Studio\Shared\Common\VSPerfCollectionTools\vs2022\;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\;C:\BuildScripts\', 'Machine')
# Set Jenkins user
ARG user=jenkins
USER ${user}

# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
