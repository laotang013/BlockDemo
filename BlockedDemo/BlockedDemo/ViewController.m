//
//  ViewController.m
//  BlockDemo
//
//  Created by 汤鹏 on 2018/11/26.
//  Copyright © 2018 Start. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
int global_i = 1; //全局变量
static int static_global_j = 2; //静态全局变量

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self test5];
}


-(void)test1
{
/*
 Block 捕获外部变量
   1.自动变量 2.静态变量 3.静态全局变量 4.全局变量
 
   2.__main_block_impl_0 结构体把自动变量捕获进来。Block语法表达式所使用的自动变量
     的值是保存进了block的结构体实例中。也就是Block自身中。
 说明:如果block外面还有很多自动变量，静态变量等。这些在block里面并不会用到，那么这些变量并不会被block捕获进来。
 也就是说在构造函数里面传入他们的值。Block捕获外部变量仅仅只捕获Block闭包里面会用到的值，其他用不到的值，它并不会去捕获。
 3.自动变量虽然被捕获进来了，但是用__cself->val 来访问的。Block仅仅捕获了val的值，并没有捕获val的内存地址。所以在__main_block_func_0这个函数中即使重写这个自动变量val的值，依旧没法去改变Block外面自动变量val的值。
 4.自动变量是以值的方式传递到Block的构造函数里面去的。Block只捕获Block中会用到的的变量，Block只捕获Block中会用到的变量。由于只捕获了自动变量的值，并非内存地址，所以Block内部不能改变自动变量的值。Block捕获的外部变量可以改变值的是静态变量，静态全局变量，全局变量。
 5. 讲解:
     问:静态全局变量和静态变量可以在block中进行修改值。
     答:静态全局变量 全局变量作用域的原因，于是可以直接在Block里面被改变。他们也存储在全局区。
        静态变量传递给Block是内存地址，所以能在Block里面直接改变值。
 6.改变自动变量的值两种方式:1.传递内存地址指针到Block中，2.改变存储区方式(__block)
 */
    static int static_k = 3;//静态变量
    int val = 4;//自动变量
    void(^myBlock)(void)=^{
        global_i++;
        static_global_j++;
        static_k++;
       NSLog(@"Block中 global_i = %d,static_global_j = %d,static_k = %d,val = %d",global_i,static_global_j,static_k,val);
    };
    global_i++;
    static_global_j++;
    static_k++;
    val++;
    NSLog(@"Block外 global_i = %d,static_global_j = %d,static_k = %d,val = %d",global_i,static_global_j,static_k,val);
    myBlock();
    
}

-(void)test2
{
    /*
     6.改变自动变量的值两种方式:1.传递内存地址指针到Block中，2.改变存储区方式(__block)
     */
    
    NSMutableString *str = [[NSMutableString alloc]initWithString:@"hello"];
    void(^myBlock)(void) = ^{
        [str appendString:@"World"];
        NSLog(@"Block中 str = %@",str);
    };
    NSLog(@"Block 外 str = %@",str);
    myBlock();
}
-(void)test3
{
    /*
     一般Block就分为三种 _NSConcreteStackBlock,_NSConcreteMallocBlock,_NSConcreteGlobalBlock。
     _NSConcreteStackBlock
         只用到外部局部变量、成员属性变量，且没有强指针引用的Block都是StackBlock。
         StackBlock的生命周期由系统控制，一旦返回之后，就会被系统销毁了。
     _NSConcreteMallocBlock:
        有强指针引用或copy修饰的成员属性引用的Block会被复制一份到堆中成为MallocBlock，没有强指针引用即销毁。
         生命周期由程序员控制。
     _NSConcreteGlobalBlock:
         没有用到外界变量或只用到全局变量、静态变量Block为_NSConcreteBlock生命周期从创建到应用程序结束。
     */
    
 

    static int static_k = 3;
    void(^myBlock)(void) = ^{
        NSLog(@"Block中 变量 = %d %d %d",static_global_j ,static_k, global_i);
    };
    NSLog(@"%@",myBlock);// <__NSGlobalBlock__: 0x10fec40e8>
    myBlock();
    
    /*
     从持有对象的角度来看:
         _NSConcreteStackBlock是不持有对象的。
         _NSConcreteMallocBlock是持有对象的
         _NSConcreteGlobalBlock也不持有对象
     */
    /*
     copy到堆上
        1.手动调用copy
        2.Block是函数的返回值
        3.Block是被强引用，Block被赋值给__strong或者id类型
        4.调用系统API入参中含有usingBlock的方法。
         以上4种情况，系统都会默认调用copy方法把Block赋复制
     */
    
    /*
     Block 生命周期
      Block是一个对象，既然是一个对象，它必然有着和对象一样的生命周期即如果没有被引用就会被释放。
     解决循环引用:
       Weak-Strong-Dance并不能保证 block所引用对象的释放时机在执行之后， 更安全的做法应该是在 block 内部使用 strongSelf 时进行 nil检测，这样可以避免上述情况。
     */
    
}
-(void)test4
{
  /*
   Block中__block实现原理
   __block的变量也被转化成了一个结构体__Block_byref_i_0 这个结构体有5个成员变量。第一个是isa指针，第二个是指向自身类型的__forwarding指针
   __forwarding指针初始化的时候指向自己。但是__block指向却不一样。
   */
    
    __block int i =0;
    NSLog(@"%p",&i);
    void(^myBlock)(void) = ^{
        i++;
        NSLog(@"这是Block里面的 %p",&i);
    };
    NSLog(@"%@",myBlock);
    myBlock();
    
    /*
     0x7fff5578cc48
     <__NSMallocBlock__: 0x608000247d70>
       这是Block里面的 0x608000239b18
       出现这个不同的原因在于这里把Block拷贝到了堆上
     地址不同 说明__forwarding指针并没有指向之前的自己。因为copy到堆上去了。
     堆上的Block会持有对象，我们把Block通过copy到了堆上，堆上会复制一份Block,，并且该Block也会继续持有该__block。当Block释放的时候，__block没有被任何对象引用，也会被释放销毁。
        ARC环境下，一旦Block赋值就会触发copy，__block就会copy到堆上。Block也是__NSMallocBlock。ARC环境下也是存在__NSStackBlock的时候，这种情况下，__block就在栈上。MRC环境下，只有copy，__block才会被复制到堆上，否则，__block一直都在栈上，block也只是__NSStackBlock，这个时候__forwarding指针就只指向自己了
     
     
     Block能捕获的变量就只有带有自动变量和静态变量了。捕获进Block的对象会被Block持有。
     */
}

-(void)test5
{
    /*
     对象的变量
     ARC环境下，Block捕获外部对象变量，是都会copy一份的，地址都不同。只不过带有__block修饰符的变量会被捕获到Block内部持有。
     在MRC环境下，__block根本不会对指针所指向的对象执行copy操作，而只是把指针进行的复制。
     而在ARC环境下，对于声明为__block的外部对象，在block内部会进行retain，以至于在block环境内能安全的引用外部对象，所以才会产生循环引用的问题！
     */
    __block id block_obj = [[NSObject alloc]init];
    id obj = [[NSObject alloc]init];
    NSLog(@"block_obj = [%@ , %p],obj = [%@ , %p]",block_obj,&block_obj,obj,&obj);
    void(^myBlock)(void)= ^{
        NSLog(@"***Block中****block_obj = [%@ , %p] , obj = [%@ , %p]",block_obj , &block_obj , obj , &obj);
    };
    myBlock();
}
@end
