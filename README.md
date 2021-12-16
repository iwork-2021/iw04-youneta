# iw04-youneta
iw04-youneta created by GitHub Classroom

# 需求
## 作业1 
1. 通过CreateML基于给定snacks数据集训练图像分类模型
2. 可针对拍照和相册中选择的图片利用训练好的模型进行snacks分类
3. 在屏幕上展示神经网络模型的分类结果
4. （非功能需求）面对不属于数据集内给定snacks类别以外的图片，或模型本身把握不准的图片，给出“我不确定”的判断
## 作业2
1. 改造snacks数据集，形成可供训练分类健康snacks模型的数据集
2. 通过CreateML基于改造的数据集训练图像分类模型
3. 可针对拍照和相册中选择的图片利用训练好的模型进行健康/非健康snacks的分类
4. 在屏幕上展示神经网络模型的分类结果
5. （非功能需求）面对不属于数据集内给定snacks类别以外的图片，或模型本身把握不准的图片，给出“我不确定”的判断

# 具体实现
demo写的太好了..基本按demo的框架实现就没有问题了，starter连storyboard都写好了..
## 模型训练
作业1训练识别食物类型的模型较为简单，用给出的数据集即可。作业2的数据集则是给予作业1的原本数据集进行改造，将原本的数据集整合起来再划分为2个分类：健康、不健康。这里我主观地主流认知中的健康/不健康食品进行分类，例如水果一类的都划分为健康，爆米花、甜甜圈等都划分为不健康，再将改造过的数据集进行训练即可。  但其实也可以用demo中已经训练好的模型用于作业2.

## 代码实现
具体的代码实现基本与demo出入不大，整个流程可以梳理为：初次启动展示choose or take a phote —— 选择图片/拍照 —— didFinishPickingMedia —— classify，handle request —— 展示结果 —— 回到第二步前。
demo中使用buffer来实时识别相机中的画面，而作业中对这块要求较低，仅要求识别单图，因此修改了一下classify方法：
```swift 
func classify(image: UIImage) {
    guard let imageCI = CIImage(image: image)
    else { return }
    let orientation = CGImagePropertyOrientation(image.imageOrientation)
    DispatchQueue.main.async {
      let handler = VNImageRequestHandler(ciImage: imageCI, orientation: orientation, options: [:] )
      do {
        try handler.perform([self.classificationRequest])
      } catch {
        print("Failed to perform classification: \(error)")
      }
    }
  }
}
```
关于给出"我不确定"的结果，这里我的理解是confidence过低时就可以认为这个判断结果是不确定、不准确的。因此这块我设置为confidence低于某个常数时就将resultLable的文本修改为I'm not sure.
