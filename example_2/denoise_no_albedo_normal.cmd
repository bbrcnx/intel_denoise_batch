@echo off
REM 通过拖拽‘文件夹’，用precompiled intel openimage denoise给文件夹内图片去噪。
REM 因为denoise程序只支持pfm格式文件所以需要提前将exr转成pfm格式文件。

echo starting...
setlocal EnableDelayedExpansion

REM intel openimage denoise程序路径
set denoiser="\\work02\ckyh_repo\software_config\open_image_denoise\bin\oidnDenoise.exe"

REM 获取拖拽到脚本上的完整文件夹路径
set input_dir=%~f1

REM 获取上级文件夹名
set input_up_folder=%~dp1
set file_ext=exr

set version_folder=%~dp1

REM 拖拽的文件夹名
set source_folder=%~n1

REM basecolor文件夹路径，这里是个固定的名字。需要提前按这个名字在nuke内输出或直接渲染。
REM set albedo_folder=%version_folder%basecolor

REM normal文件夹路径，这里是个固定的名字。需要提前按这个名字在nuke内输出或直接渲染。
REM set n_folder=%version_folder%n

REM 设置中间转换的pfm文件路径
set pfm_source_folder=%version_folder%pfm_%~n1
REM set pfm_albedo_folder=%version_folder%pfm_albedo
REM set pfm_n_folder=%version_folder%pfm_n
set pfm_denoise_folder=%~dp1pfm_denoise_%~n1

REM 设置最终输出的exr文件路径。
set denoise_folder=%~dp1denoise_%~n1

REM 创建文件夹
if not exist %pfm_source_folder% ( md %pfm_source_folder% )
REM if not exist %pfm_albedo_folder% ( md %pfm_albedo_folder% )
REM if not exist %pfm_n_folder% ( md %pfm_n_folder% )
if not exist %pfm_denoise_folder% ( md %pfm_denoise_folder% )
if not exist %denoise_folder% ( md %denoise_folder% )

REM 开始转换
for %%g in (%~f1\*.%file_ext%) do (

REM 将输入文件转成pfm文件。
REM %%~nxg是包含扩展名的完整文件名。%%~ng是不包含扩展名的文件名。
REM -colorspace RGB是将输入转成linear colorspace。 -colorspace sRGB是将输入转成sRGB colorspace。
REM -set colorspace RGB是将linear colorspace的profile写到图片内，但并不转换数据。
REM -endian LSB是denoiser对图片格式的要求，图片需要是little endian格式的。
magick  %input_dir%\%%~nxg  -colorspace RGB -endian LSB %pfm_source_folder%\%%~ng.pfm
REM magick  %albedo_folder%\%%~nxg  -colorspace RGB -endian LSB %pfm_albedo_folder%\%%~ng.pfm
REM magick  %n_folder%\%%~nxg  -colorspace RGB -endian LSB %pfm_n_folder%\%%~ng.pfm

REM denoiser 有basecolor层和normal层效果才好。
REM -ldr 指定输入的图片是低动态。
REM -hdr 指定输入的图片是高动态。
REM -alb 指定abledo层。
REM -nrm 指定normal层。
REM -o 输出位置。
REM 官方compiled的windows版本只支持pfm格式图片，所以需要用imagemagick转。
%denoiser% -hdr %pfm_source_folder%\%%~ng.pfm -o %pfm_denoise_folder%\%%~ng.pfm

REM 转exr不需要加-colorspace RGB,加了反而会出错。
magick  %pfm_denoise_folder%\%%~ng.pfm %denoise_folder%\%%~ng.exr

echo %denoise_folder%\%%~ng.exr
)

REM 删除pfm临时文件
rmdir /S /Q %pfm_denoise_folder%\
rmdir /S /Q %pfm_source_folder%\


pause
