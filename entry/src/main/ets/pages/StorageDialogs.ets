import { Item, ItemCategory } from './ItemModel';

// 新增物品时弹出的对话框
@CustomDialog
export struct addDialog{
  controller?:CustomDialogController;
  @State name: string = '';
  @State location: string = '';
  @State countText: string = '1';
  @State category: ItemCategory = Object.values(ItemCategory)[0];
  @State note: string = '';

  // 定义添加物品函数
  // index里面把addFn已经交过来了，这里已经承接。我们后续给他塞参数即可
  addFn:(item:Item)=>Promise<void> = async ()=>{}
  closeFn:()=>void = ()=>{}  // 没有模拟器的找补办法

  // 定义如何渲染
  build(){
    Column({space:10}){
      // 标题
      Text(`增加物品`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      // 第一行：物品名称
      TextInput({placeholder:`物品名称`})
        .onChange((value:string)=>{this.name = value})
        .width(`100%`)
      // 第二行：物品位置 物品数量
      Row({space:10}){
        TextInput({placeholder:`物品位置`})
          .layoutWeight(1)
          .onChange((value:string)=>{this.location = value})
        TextInput({placeholder:`物品数量`})
          .layoutWeight(1)
          .onChange((value:string)=>{this.countText = value})
      }
        .width(`100%`)
      // 第三行：类别 切换类别的按钮
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
      // 第四行：输入备注
      TextInput({placeholder:`备注`})
        .onChange((value:string)=>{this.note = value})
      // 第五行：两个按钮
      Row({space:10}){
        // 取消按钮
        Button(`取消`)
          .layoutWeight(1)
          .onClick(()=>{
            this.closeFn()})
        // 确定按钮：给addFn塞参数，以修改itemList
        Button(`确定`)
          .layoutWeight(1)
          .onClick(async ()=>{
            const newId: string = `${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
            const newItem:Item = new Item(newId, this.name.trim(), this.location.trim(), Number(this.countText) || 1, this.category, this.note.trim())
            await this.addFn(newItem)
            this.closeFn()
          })
      }
    }
  }
}

// 编辑的交互逻辑
@CustomDialog
export struct editdialog{
  controller?:CustomDialogController;
  targetItem?: Item
  @State name: string = '';
  @State location: string = '';
  @State countText: string = '1';
  @State category: ItemCategory = Object.values(ItemCategory)[0];
  @State note: string = '';
  closeFn:()=>void = ()=>{}
  editFn:(item:Item)=>Promise<void> = async ()=>{}
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
      // 第一行：物品名称
      TextInput({placeholder:`输入物品名称`, text:this.name})
        .onChange((value:string)=>{this.name = value})
      // 第二行：物品位置 物品数量
      Row({space:10}){
        TextInput({placeholder:`输入物品位置`, text:this.location})
          .layoutWeight(1)
          .onChange((value:string)=>{this.location = value})
        TextInput({placeholder:`输入物品数量`, text:this.countText})
          .layoutWeight(1)
          .onChange((value:string)=>{this.countText = value})
      }
        .width(`100%`)
      // 第三行：类别 切换类别的按钮
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
      // 第四行：输入备注
      TextInput({placeholder:`输入物品备注`, text:this.note})
        .onChange((value:string)=>{this.note = value})
      // 第五行：两个按钮
      Row({space:10}){
        // 取消按钮
        Button(`取消`)
          .layoutWeight(1)
          .onClick(()=>{
            this.closeFn()})
        // 确定按钮：给addFn塞参数，以修改itemList
        Button(`确定`)
          .layoutWeight(1)
          .onClick(async ()=>{
            const keepId: string = this.targetItem ? this.targetItem.id : `${Date.now()}`;
            const updatedItem:Item = new Item(keepId, this.name.trim(), this.location.trim(), Number(this.countText) || 1, this.category, this.note.trim())
            await this.editFn(updatedItem)
            this.closeFn()
          })
      }
    }
  }
}