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

  constructor(id:string, name: string, location: string, count: number, category: ItemCategory, note?: string) {
    this.id = id;
    this.name = name;
    this.location = location;
    this.count = count;
    this.category = category;
    this.note = note;
  }
}