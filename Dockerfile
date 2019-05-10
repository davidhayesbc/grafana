# escape=`
ARG nanoServerVersion=1809
FROM mcr.microsoft.com/powershell:nanoserver-$nanoServerVersion as build
ARG grafanaVersion
SHELL [ "pwsh", "-command" ]

#Download Grafana
ENV grafanaVersion $grafanaVersion
ENV grafanaUrl https://dl.grafana.com/oss/release/grafana-${grafanaVersion}.windows-amd64.zip 
RUN md c:\temp
RUN Invoke-WebRequest ($env:grafanaUrl) -UseBasicParsing -OutFile c:\temp\grafana.zip

#extract the archive
RUN Expand-Archive c:\temp\grafana.zip c:\temp\grafana

#Move the Grafana Directory to take aout the version number
RUN mv c:\temp\grafana\grafana-$env:grafanaVersion\ c:\temp\grafana\grafana

# Second build stage, copy the extracted files into a nanoserver container
FROM mcr.microsoft.com/windows/nanoserver:$nanoServerVersion
COPY --from=build c:/temp/grafana/grafana/ /grafana
LABEL maintainer="david.hayes@spindriftpages.net"

#Expose a port from the container
EXPOSE     3000
WORKDIR C:\grafana\bin
ENTRYPOINT [ "C:\\grafana\\bin\\grafana-server.exe" ]
