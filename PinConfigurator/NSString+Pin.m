//
//  NSString+Pin.m
//  PinConfigurator
//
//  Created by Ben Baker on 2/7/19.
//  Copyright © 2019 Ben Baker. All rights 保留.
//

#import "NSString+Pin.h"

@implementation NSString (Pin)

const char *gPinColorArray[] = { "未知", "黑", "灰", "蓝", "绿", "红", "橙", "黄", "紫", "粉", "保留1", "未知", "未知", "保留2", "白", "其它" };
const char *gPinMisc[] = { "插孔检测覆盖", "保留", "保留", "保留" };
const char *gPinDefaultDeviceArray[] = { "线路输出", "外放", "耳机", "CD", "光纤输出", "其它数码输出", "调制解调器线路侧", "调制解调器手机侧", "线路输入", "AUX", "内置麦克风", "电话", "光纤输入", "其它数码输入", "保留", "其它" };
const char *gPinConnector[] = { "未知", "1/8\" Stereo/Mono", "1/4\" Stereo/Mono", "ATAPI Internal", "RCA", "Optical", "其它 Digital", "其它 Analog", "Multichannel Analog", "XLR/Professional", "RJ-11 (Modem)", "Combination", "未知", "未知", "未知", "其它" };
const char *gPinPort[] = { "插孔", "无连接", "固定的", "插孔+内置" };
const char *gPinGeometricLocation[] = { "N/A", "后", "前", "左", "右", "顶", "底", "特殊", "特殊", "特殊", "保留", "保留", "保留", "保留", "保留", "保留" };
const char *gPinGrossLocation[] = { "外部", "内置", "分离", "其它" };
const char *gPinGrossSpecial7[] = { "后面板", "提升", "特别", "移动盒子里面" };
const char *gPinGrossSpecial8[] = { "Drive Bay", "Digital Display", "Special", "Mobile Lid-Outside" };
const char *gPinGrossSpecial9[] = { "Special", "ATAPI", "Special", "Special" };
const char *gPinEAPD[] = { "BTL", "EAPD", "L/R Swap" };

+ (NSString *)pinColor:(uint8_t)value
{
	return [NSString stringWithUTF8String:gPinColorArray[value & 0xF]];
}

+ (NSString *)pinMisc:(uint8_t)value
{
	return [NSString stringWithUTF8String:gPinMisc[value & 0x3]];
}

+ (NSString *)pinDefaultDevice:(uint8_t)value
{
	return [NSString stringWithUTF8String:gPinDefaultDeviceArray[value & 0xF]];
}

+ (NSString *)pinConnector:(uint8_t)value
{
	return [NSString stringWithUTF8String:gPinConnector[value & 0xF]];
}

+ (NSString *)pinPort:(uint8_t)value
{
	return [NSString stringWithUTF8String:gPinPort[value & 0x3]];
}

+ (NSString *)pinGrossLocation:(uint8_t)value;
{
	return [NSString stringWithUTF8String:gPinGrossLocation[value]];
}

+ (NSString *)pinLocation:(uint8_t)grossLocation geometricLocation:(uint8_t)geometricLocation;
{
	if (geometricLocation == 0x7)
		return [NSString stringWithUTF8String:gPinGrossSpecial7[grossLocation]];
	else if (geometricLocation == 0x8)
		return [NSString stringWithUTF8String:gPinGrossSpecial8[grossLocation]];
	else if (geometricLocation == 0x9)
		return [NSString stringWithUTF8String:gPinGrossSpecial9[grossLocation]];

	return [NSString stringWithUTF8String:gPinGeometricLocation[geometricLocation]];
}

+ (NSString *)pinEAPD:(uint8_t)value;
{
	return [NSString stringWithUTF8String:gPinEAPD[value & 0x7]];
}

+ (NSString *)pinConfigDescription:(uint8_t *)value
{
	if (!value || strlen((const char *)value) != 8)
		return @"Invalid pin config";
	
	uint8_t cad = value[0] - 48;
	const char *name = (const char *)&value[2];
	uint8_t command = value[5];
	uint8_t port = strtol((const char *)&value[6], 0, 16);
	uint8_t connector = strtol((const char *)&value[7], 0, 16);
	uint8_t grossLocation = (connector >> 4);
	uint8_t geometricLocation = (connector & 0xF);
	NSString *configDescription = 0;
	uint32_t hid = (uint32_t)strtol(name, 0, 16);
	
	switch (command)
	{
		case 0x43:
		case 0x63:
			configDescription = [NSString stringWithFormat:@" command: %c \n\t   group: %c \n\t   index: %c", command, value[6], value[7]];
			break;
		case 0x44:
		case 0x64:
			configDescription = [NSString stringWithFormat:@" command: %c \n\t   color: %@ (%c) \n\t    misc: %c", command, [NSString pinColor:port], value[6], value[7]];
			break;
		case 0x45:
		case 0x65:
			configDescription = [NSString stringWithFormat:@" command: %c \n\t  device: %@ (%c)\n\t    conn: %@ (%c)", command, [NSString pinDefaultDevice:port], value[6], [NSString pinConnector:connector], value[7]];
			break;
		case 0x46:
		case 0x66:
			configDescription = [NSString stringWithFormat:@" command: %c \n\t    port: %@ (%c) \n\tlocation: %@ (%c)", command, [NSString pinPort:port], value[6], [NSString pinLocation:grossLocation geometricLocation:geometricLocation], value[7]];
			break;
		default:
			break;
	}
	
	return [NSString stringWithFormat:@"{\n\t     cad: %d \n\t     hid: %d (%s)\n\t%@\n}", cad, hid, name, configDescription];
}

+ (NSString *)pinDefaultDescription:(uint8_t *)value
{
	return @"";
}

@end
