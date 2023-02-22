param(
    [Parameter(Mandatory=$true)]
    [string]$HostName
)

if (Test-Path -Path ./setup.zip) {
    Remove-Item -Confirm:$false -Path ./setup.zip
}

Compress-Archive -Path * -DestinationPath ./setup.zip

adb push ./setup.zip /home/phablet/
adb shell -- mkdir -p /home/phablet/setup
adb shell -- cd /home/phablet/setup/ `&`& rm *
adb shell -- cd /home/phablet/setup/ `&`& unzip /home/phablet/setup.zip `&`& chmod +x ./setup.sh `&`& sudo -S ./setup.sh $HostName