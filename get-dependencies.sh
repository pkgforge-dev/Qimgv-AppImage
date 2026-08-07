#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake             \
	exiv2             \
	kvantum           \
	lxqt-qtplugin     \
	mpv               \
	ninja             \
	opencv            \
	pipewire-audio    \
	pipewire-jack     \
	qt6-5compat       \
	qt6-imageformats  \
	qt6-multimedia    \
	qt6-svg           \
	qt6-tools         \
	qt6ct

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

# build qimgv manually from the latest stable tag
echo "Building qimgv..."
echo "---------------------------------------------------------------"
git clone https://github.com/easymodo/qimgv.git ./qimgv
cd ./qimgv

git fetch --tags origin
TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -1)
git checkout "$TAG"

# backport fixes from master to build with latest mpv opencv exiv2 versions
sed -i -e 's/{get_proc_address, nullptr, nullptr}/{get_proc_address, nullptr}/' ./plugins/player_mpv/src/mpvwidget.cpp
sed -i -e 's|<opencv4/opencv2/|<opencv2/|g' ./qimgv/3rdparty/QtOpenCV/cvmatandqimage.h ./qimgv/3rdparty/QtOpenCV/cvmatandqimage.cpp
sed -i -e '/^    catch (Exiv2::BasicError<CharType> e) {$/,/^    }$/d' ./qimgv/sourcecontainers/documentinfo.cpp

mkdir -p ./build
cd ./build
cmake ../ \
	-G Ninja                    \
	-DCMAKE_BUILD_TYPE=Release  \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_INSTALL_LIBDIR=lib
cmake --build ./ -j"$(nproc)"
cmake --install ./

echo "$TAG" > ~/version
