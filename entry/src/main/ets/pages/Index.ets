import { Action } from "@ohos.multimodalInput.touchEvent";

export enum ItemCategory {
  Daily = "日常用品",
  Medicine = "药品",
  Appliance = "电器",
  Valuables = "贵重物品",
  Certificate = "证件",
  Document = "文件",
  Clothing = "衣物",
  Supplement = "保健品",
  Accessory = "配件",
  Tool = "工具",
  Other = "其他"
}

export class Item {
  id: string;
  name: string;
  location: string;
  count: number;
  category: ItemCategory;
  note?: string;

  constructor(name: string, location: string, count: number, category: ItemCategory, note?: string) {
    this.id = new Date().getTime().toString() + Math.random().toString();
    this.name = name;
    this.location = location;
    this.count = count;
    this.category = category;
    this.note = note;
  }
}

// 新增物品时弹出的对话框
@CustomDialog
struct addDialog{
  controller?:CustomDialogController;
  @State name: string = '';
  @State location: string = '';
  @State countText: string = '1';
  @State category: ItemCategory = Object.values(ItemCategory)[0];
  @State note: string = '';

  // 定义添加物品函数
  // index里面把addFn已经交过来了，这里已经承接。我们后续给他塞参数即可
  addFn:(item:Item)=>void = ()=>{}
  closeFn:()=>void = ()=>{}  // 没有模拟器的找补办法

  // 定义如何渲染
  build(){
    Column({space:10}){
      // 标题
      Text(`增加物品`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      // 第一行：物品名称 物品位置
      Row({space:10}){
        TextInput({placeholder:`物品名称`})
          .layoutWeight(1)
          .onChange((value:string)=>{this.name = value})
        TextInput({placeholder:`物品位置`})
          .layoutWeight(1)
          .onChange((value:string)=>{this.location = value})
      }
        .width(`100%`)
      // 第二行：类别 切换类别的按钮
      Row({space:10}){
        Text(`${this.category}`)
          .layoutWeight(2)
        Button(`点击以切换类别`)
          .layoutWeight(1)
          .onClick(()=>{
            const list = Object.values(ItemCategory)
            let idx = list.indexOf(this.category)
            this.category = list[(idx+1)%list.length]
          })
      }
      // 第三行：输入备注
      TextInput({placeholder:`备注`})
        .onChange((value:string)=>{this.note = value})
      // 第四行：两个按钮
      Row({space:10}){
        // 取消按钮
        Button(`取消`)
          .layoutWeight(1)
          .onClick(()=>{
            this.closeFn()})
        // 确定按钮：给addFn塞参数，以修改itemList
        Button(`确定`)
          .layoutWeight(1)
          .onClick(()=>{
            const newItem:Item = new Item(this.name.trim(), this.location.trim(), Number(this.countText) || 1, this.category, this.note.trim())
            this.addFn(newItem)
            this.closeFn()
          })
      }
    }
  }
}

// 编辑的交互逻辑
@CustomDialog
struct editdialog{
  controller?:CustomDialogController;
  targetItem?: Item
  @State name: string = '';
  @State location: string = '';
  @State countText: string = '1';
  @State category: ItemCategory = Object.values(ItemCategory)[0];
  @State note: string = '';
  closeFn:()=>void = ()=>{}
  editFn:(item:Item)=>void = ()=>{}
  getTargetItemFn:()=>Item|undefined = ():Item|undefined=>{return undefined}

  aboutToAppear(): void {
    this.targetItem = this.getTargetItemFn()
    if (this.targetItem) {
      this.name = this.targetItem.name;
      this.location = this.targetItem.location;
      this.countText = this.targetItem.count.toString();
      this.category = this.targetItem.category;
      this.note = this.targetItem.note ?? '';
    }
  }

  build(){
    Column({space:10}){
      // 标题
      Text(`编辑物品`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      // 第一行：物品名称 物品位置
      Row({space:10}){
        TextInput({placeholder:`输入物品位置`})
          .layoutWeight(1)
          .onChange((value:string)=>{this.location = value})
        TextInput({placeholder:`输入物品数量`})
          .layoutWeight(1)
          .onChange((value:string)=>{this.countText = value})
      }
      .width(`100%`)
      // 第二行：输入备注
      TextInput({placeholder:`输入物品备注`})
        .onChange((value:string)=>{this.note = value})
      // 第三行：两个按钮
      Row({space:10}){
        // 取消按钮
        Button(`取消`)
          .layoutWeight(1)
          .onClick(()=>{
            this.closeFn()})
        // 确定按钮：给addFn塞参数，以修改itemList
        Button(`确定`)
          .layoutWeight(1)
          .onClick(()=>{
            const updatedItem:Item = new Item(this.name.trim(), this.location.trim(), Number(this.countText) || 1, this.category, this.note.trim())
            if (this.targetItem) {
              updatedItem.id = this.targetItem.id
            }
            this.editFn(updatedItem)
            this.closeFn()
          })
      }
    }
  }
}

@Entry
@Component
struct Index {
  // 状态变量：物品列表
  @State itemList: Item[] = [
    new Item("健身衣物", "躺椅上", 3, ItemCategory.Clothing, "红色短裤"),
    new Item("手表带", "工具箱", 1, ItemCategory.Other),
    new Item("螺丝刀套装", "工具箱", 1, ItemCategory.Tool, "十字和一字"),
    new Item("感冒药", "柜子第三层", 5, ItemCategory.Medicine),
    new Item("手机充电线", "右边抽屉", 2, ItemCategory.Accessory)
  ];

  dialogController:CustomDialogController|null = null
  editDialogController:CustomDialogController|null = null
  idRecorder:string = ""  //编辑功能要用的，用于记录ForEach传出来的参数

  // 状态变量：搜索关键词
  @State query: string = '';

  // 用于给ForEach的第一个参数做搜索的filter
  searchFn = (item:Item):boolean =>
  {
    if(this.query==="") return true
    return item.name.includes(this.query) || item.location.includes(this.query)
  }

  //给长按删除的filter用的函数
  deleteFn = (targetId:string):void=>
  {
    this.itemList = this.itemList.filter((item:Item)=>{return targetId!==item.id})
  }

  addFn = (item:Item):void =>
  {
    this.itemList = [...this.itemList, item]
  }

  closeFn = ():void =>
  {
    this.dialogController?.close()
    this.editDialogController?.close()
  }

  editFn = (item:Item):void =>
  {
    const idx:number = this.itemList.findIndex((item:Item)=>{return item.id===this.idRecorder})
    if(idx!==-1){
      const newItemList:Item[] = [...this.itemList]
      newItemList[idx] = item
      this.itemList = newItemList
    }
  }

  getTargetItem = ():Item|undefined =>
  {
    return this.itemList.find((item:Item)=>{return item.id===this.idRecorder})
  }

  // dialogController的builder的回调函数
  @Builder
  addDialogBuilder(){
    addDialog({addFn:this.addFn, closeFn:this.closeFn})
  }

  // 编辑功能的CustomDialogController的回调函数
  @Builder
  editDialogBuilder(){
    editdialog({
      editFn:this.editFn,
      closeFn:this.closeFn,
      getTargetItemFn:this.getTargetItem
    })
  }


  build() {
    Column() {
      //标题
      Text(`家庭储物管理系统`)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({top:20,bottom:10})
      //搜索框
      Search({placeholder:"搜索物品名称或位置"})
        .width("90%")
        .height(40)
        .margin({bottom:15})
        .onChange((value)=> this.query=value)
      //展示列表栏
      List(){
        //ForEach第一个参数：要操作的数组
        ForEach(this.itemList.filter(this.searchFn), (item:Item)=>{
          ListItem(){
            Column(){
              // 第一排
              Row(){
                Text(item.name)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                Text(item.category)
                  .fontSize(12)
                  .fontColor(Color.White)
                  .backgroundColor(Color.Pink)
                  .padding({top:6,bottom:6,left:6,right:6})
                  .borderRadius(10)
              }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              // 第二排
              Text(`📍${item.location}`)
                .margin({top:8,bottom:8})
                .width("100%")
                .fontSize(12)
                .fontColor(Color.Gray)
              // 第三排
              Row() {
                Row() {
                  Text(`数量:${item.count}`)
                    .margin({ right: 15 })
                    .fontSize(15)
                  if (item.note) {
                    Text(`备注:${item.note}`)
                      .fontSize(15)
                  }
                }
                Button("删除")
                  .fontSize(12)
                  .height(26)
                  .padding({ left: 8, right: 8 })
                  .onClick(() => {
                    AlertDialog.show({
                      title:`确定删除`,
                      message:`确定要删除${item.name}吗`,
                      primaryButton:{
                        value:"取消",
                        action:()=>{}
                      },
                      secondaryButton:{
                        value:'确定',
                        action:()=>{
                          this.deleteFn(item.id)
                        }
                      }
                    })
                  })
              }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)
            }
              .width('100%')
              .padding(16)                    // 1. 内边距：让文字不要贴着卡片边缘
              .backgroundColor(Color.White)   // 2. 背景色：设置成白色，和整体的灰色背景（#F1F3F5）区分开
              .borderRadius(12)
              .shadow({radius: 4, color: '#1A000000',offsetY: 2})
          }
            .margin({bottom:5,top:5})
            .gesture(  //长按编辑
              LongPressGesture()
                .onAction(()=>{
                  this.idRecorder = item.id
                  this.editDialogController = new CustomDialogController({
                    builder:()=>{this.editDialogBuilder()}
                  })
                  this.editDialogController.open()
                })
            )
        },(item: Item) => `${item.id}_${item.location}_${item.count}_${item.note}`)
      }
      .layoutWeight(1) //吃掉其他组件的剩余空间
      // 新增物品按钮
      Button(`+`)
        .fontSize(`15`)
        .alignSelf(ItemAlign.End) // 让这个Button在父容器的交叉轴（水平方向）靠右
        .margin({top:5,bottom:10})
        .onClick(()=>{
          this.dialogController = new CustomDialogController({
            builder:(()=>{this.addDialogBuilder()}),
            autoCancel:false,
          })
          this.dialogController.open()
        })

    }
      .width("100%")
      .height("100%")                // 撑满屏幕高度
      .backgroundColor('#F1F3F5')    // 设置浅灰色背景
  }
}

