import { Item, ItemCategory } from './ItemModel';
import { addDialog, editdialog } from './StorageDialogs';
import { StorageDb } from './storageDb';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  // 状态变量：物品列表
  @State itemList: Item[] = [];
  private db:StorageDb = new StorageDb()

  async aboutToAppear(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    await this.db.init(context)
    this.itemList = await this.db.queryAll()
  }

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

  // 删除功能
  deleteFn = async (targetId:string):Promise<void>=>
  {
    await this.db.deleteItem(targetId)
    this.itemList = await this.db.queryAll()
  }

  addFn = async (item: Item): Promise<void> => {
    await this.db.insertItem(item)
    this.itemList = await this.db.queryAll()
  }

  closeFn = ():void =>
  {
    this.dialogController?.close()
    this.editDialogController?.close()
  }

  editFn = async (item:Item):Promise<void> =>
  {
    await this.db.updateItem(item)
    this.itemList = await this.db.queryAll()
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
                        action:async ()=>{
                          await this.deleteFn(item.id)
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

