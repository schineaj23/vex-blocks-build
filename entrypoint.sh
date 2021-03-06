#!/bin/bash

# Have to build from source because apt is outdated
echo "Downloading ARM GCC Toolchain..."

curl -L https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2 -o gcc-arm-none-eabi.tar.bz2
tar -xjf gcc-arm-none-eabi.tar.bz2
export PATH="${PATH}:/github/workspace/gcc-arm-none-eabi-10-2020-q4-major/bin"

# No linux option so have to extract from mac dmg
echo "Downloading VEX PROS's SDK"
curl -L https://content.vexrobotics.com/vexcode/v5code/VEXcodeProV5_2_0_1.dmg -o vexcode.dmg
7z x vexcode.dmg || :
7z x Payload~ ./VEXcode\ Pro\ V5.app/Contents/Resources/sdk -osdk_temp || :
mkdir ~/sdk
mv sdk_temp/VEXcode\ Pro\ V5.app/Contents/Resources/sdk/* ~/sdk
rm -rf _vex*_ _vex*_.dmg sdk_temp/ Payload~

# Download dummy project to build
fileid="1TAe2Ywms1aM5L0wOyTt-hR3PHUNJlYne"
filename="project.zip"
curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${fileid}" -o ${filename}
7z x project.zip

# Create c++ file from v5blocks
# credit to @pbchase
echo "Creating c++ file from v5blocks file"
cat $1 | jq -r '. | .cpp' | perl -pe "s/\\\n/\n/g;" > main.cpp
mv main.cpp project/src/main.cpp

echo "Building project..."
cd project
make