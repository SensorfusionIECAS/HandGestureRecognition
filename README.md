# HandGestureRecognition
Hand gesture recogniiton algorithm on a resource-limited interactive wristband. This HGR algorithm is based on matching axis-crossing codes.

## AxisCrossingCodeHGR 手势识别主文件夹
###  main.m
    主函数，处理的是采集时由C++解算得到的地球系线加速度，直接运行就可以输出每个样本的识别结果、准确率、运算时间。其中需要手动修改所要识别手势的代号
    1 cwv (clockwise vetical)
    2 ccwv (counterclockwise vertical)
    3 cwh (clockwise horizontal)
    4 ccwh (counterclockwise horizontal)
    5 up
    6 down
    7 left
    8 right
###  mainOld.m
    旧的主函数，可以不用，放上来就是记录一下，处理的是采集得到的原始IMU数据，包括额外转换到地球系线加速度，由于细微参数不同，且不像C++版的代码一样
    有归零设置，所以和main.m还是有差别，没有仔细调这个版本。
###  ObserveCodeStream.m
    查看具体样本的码流，输出样本的码流图。当发现识别错误的样本时候，用来查看细节。
    
## dataset 数据集文件
###  Segment.m
    采集的时候是一整个文件么，用这个函数分割事件，把样本存到cell里就是main函数要用的数据集了。
    分割方法是寻找事件开始点（刚才不动，现在动了）和结束点（刚才动，现在不动了），基本思想是这样，然后用滑动窗口平均提高可靠性。\
    
## GenerateFigures 生成论文中的图
  这里面的文件就都是用于生成论文里的图了，Figure 2 还包括录制 video abstract.

