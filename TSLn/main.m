//
//  main.m
//  TSLn
//
//  Created by Fish on 15/7/15.
//  Copyright (c) 2015年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

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
        
        NSLog(@"Ln..");
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
        }
    }
	return 0;
}

