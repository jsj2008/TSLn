//
//  main.m
//  TSLn
//
//  Created by Fish on 15/7/15.
//  Copyright (c) 2015年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

//#define P4U_DAEMON

int main (int argc, const char * argv[])
{
    //设置uid为0,以root权限启动
    setuid(0);
    setgid(0);
    
    @autoreleasepool
    {
        NSString* sourcePath = nil;
        NSString* daemonName = nil;
        //判断参数个数 类型
        //设置权限
#ifdef P4U_DAEMON
        system("chown -R mobile:mobile /private/var/mobile/Media/Play4UStore");
        sourcePath = @"/Applications/Play4UStore.app";
        daemonName = @"P4UDaemon";
#else
        system("chown -R mobile:mobile /private/var/mobile/Media/TouchSprite");
        sourcePath = @"/Applications/TouchSprite.app";
        daemonName = @"TSDaemon";
#endif
        
        if (argc > 2)
        {
            int type = atoi(argv[1]);
            //创建连接
            if (type == 1 && argc == 4)
            {
                /*
                NSString* cmd = [NSString stringWithFormat:@"ln -s %s %s",argv[2],argv[3]];
                system([cmd UTF8String]);
                */
                
                //目标路径文件名
                //判断default服务是否存在
                NSFileManager* fileManager = [NSFileManager defaultManager];
                NSString* srvpath = [sourcePath stringByAppendingPathComponent:@"default"];
                
                if (![fileManager fileExistsAtPath:srvpath])
                {
                    NSString* cmd = [NSString stringWithFormat:@"cp %@/%@ %@",sourcePath,daemonName,srvpath];
                    system([cmd UTF8String]);
                    
                    NSString* cmd1 = [NSString stringWithFormat:@"chown root:wheel %@",srvpath];
                    NSString* cmd2 = [NSString stringWithFormat:@"chmod 755 %@",srvpath];
                    NSString* cmd3 = [NSString stringWithFormat:@"chmod u+s %@",srvpath];
                    system([cmd1 UTF8String]);
                    system([cmd2 UTF8String]);
                    system([cmd3 UTF8String]);
                }
                
                //修改进程名
                NSString* targetPath = [NSString stringWithUTF8String:argv[3]];
                NSString* cmd = [NSString stringWithFormat:@"mv %@ %@/%@",srvpath,sourcePath,[targetPath lastPathComponent]];
                system([cmd UTF8String]);
                
                /*
                NSString* cmd1 = [NSString stringWithFormat:@"cp %s %s",argv[2],argv[3]];
                NSString* cmd2 = [NSString stringWithFormat:@"chown 0:0 %s",argv[3]];
                NSString* cmd3 = [NSString stringWithFormat:@"chmod 4755 %s",argv[3]];
                
                system([cmd1 UTF8String]);
                system([cmd2 UTF8String]);
                system([cmd3 UTF8String]);
                */
            }
            //删除连接
            else if (type == 2 && argc == 3)
            {
                /*
                NSString* cmd = [NSString stringWithFormat:@"rm -rf %s",argv[2]];
                */
                //恢复原来的名字
                NSString* srvpath = [sourcePath stringByAppendingPathComponent:@"default"];
                NSString* targetPath = [NSString stringWithUTF8String:argv[2]];
                NSString* cmd = [NSString stringWithFormat:@"mv %@/%@ %@",sourcePath,[targetPath lastPathComponent],srvpath];
                
                system([cmd UTF8String]);
            }
            //判断服务MD5
            else if (type == 3 && argc == 3)
            {
                NSString* path = [NSString stringWithUTF8String:argv[2]];
                NSData		* data		= [NSData dataWithContentsOfFile:path];
                const char	* cStr		= (const char *) data.bytes;
                
                unsigned char result[CC_MD5_DIGEST_LENGTH];
                CC_MD5 (cStr, (CC_LONG)data.length, result);
                
                NSString* ret = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                       result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                       result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
                
                //发送MD5
                /* 创建URL对象 */
                NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"https://auth.touchsprite.com/getPlay4UKey?d=%@",ret]];
                /* 创建一个请求,参数分别为URL,缓存方式(忽略本地缓存),连接超时时间 */
                NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
                                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                    timeoutInterval:10.0f];
                /* 连接方式为Post */
                [request setHTTPMethod:@"GET"];
                /* 发起同步连接 */
                NSHTTPURLResponse	* response	= nil;
                NSError			* error		= nil;
                NSData			* recvdata  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if ( !error )
                {
                    if (recvdata)
                    {
                        NSString* recvstr = [[NSString alloc] initWithData:recvdata encoding:NSUTF8StringEncoding];
                        if ([recvstr isEqualToString:@"getKeySuccess"])
                        {
                            NSString* kpn = [NSString stringWithFormat:@"killall %@",[path lastPathComponent]];
                            system([kpn UTF8String]);
                        }
                        [recvstr release];
                    }
                }
            }
        }
    }
	return 0;
}

