import relationalStore from '@ohos.data.relationalStore';
import { common } from '@kit.AbilityKit';
import { Item, ItemCategory } from './ItemModel';

const DB_NAME = 'home_storage.db';
const TABLE_NAME = 'ITEMS';

const CREATE_TABLE_SQL: string = `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    count INTEGER NOT NULL,
    category TEXT NOT NULL,
    note TEXT
  )`;

export class StorageDb {
  // 创建一个数据库管理器
  private rdbStore:relationalStore.RdbStore|null = null;

  // 初始化数据库
  async init(context: common.UIAbilityContext): Promise<void>
  {
    if(this.rdbStore) return;
    // 1. 配置好数据库控制器要连接的数据库名以及安全等级
    const rdbConfig:relationalStore.StoreConfig = {
      name:DB_NAME,
      securityLevel:relationalStore.SecurityLevel.S1
    }
    // 2. 给到系统数据库路径以及配置，拿到数据库控制器实例
    // 2.1 此时已经在磁盘上建立数据库，所以是异步操作
    this.rdbStore = await relationalStore.getRdbStore(context,rdbConfig)
    // 3. 在磁盘上建立的数据库上建立TABLE_NAME这张表
    await this.rdbStore.executeSql(CREATE_TABLE_SQL)
  }

  // 查询所有物品
  async queryAll(): Promise<Item[]> {
    if (!this.rdbStore) return [];
    // 1. 创建查询语句实例：要查询的表名、条件
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME)
    // 2. 真正的执行查询，通过数据库控制器
    // 2.1 query的第一个函数：查询语句
    // 2.2 query的第二个参数：需要获取的列的列明，用''包住
    const resultSet:relationalStore.ResultSet = await this.rdbStore.query(predicates,[
      'id',
      'name',
      'location',
      'count',
      'category',
      'note'
    ])
    // 3. resultSet是一个数据库行集合，要将其转化为Item[]再返回
    const list:Item[] = []
    try{ // 无论是否成功将resultSet转化为Item[]，都要释放resultSet
      while(resultSet.goToNextRow()){ // goToNextRow():游标指向下一个，如果有值，就返回true，否则false
        const id = resultSet.getString(resultSet.getColumnIndex('id'))
        const name = resultSet.getString(resultSet.getColumnIndex('name'))
        const location: string = resultSet.getString(resultSet.getColumnIndex('location'));
        const count: number = resultSet.getLong(resultSet.getColumnIndex('count'));
        const categoryStr: string = resultSet.getString(resultSet.getColumnIndex('category'));
        const noteStr: string = resultSet.getString(resultSet.getColumnIndex('note'));
        const item = new Item(id,name,location,count,
          categoryStr as ItemCategory,
          noteStr || undefined)
        list.push(item)
      }
    } finally {
      resultSet.close()
    }
  return list;
  }

  // 新增一条物品
  async insertItem(item: Item): Promise<void> {
    if (!this.rdbStore) return ;
    // 1. 数据库接口insert,update等只认valuesBucket
    // 1. 所以要先把Item打包成valueBucket，之后才能放入数据库
    const valuesBucket:relationalStore.ValuesBucket = {
      id:item.id,
      name:item.name,
      location: item.location,
      count: item.count,
      category: item.category,
      //如果item.note是undefined，就存空字符串''
      note: item.note ?? ''
    }
    // 2. 插入数据库，是异步操作
    await this.rdbStore.insert(TABLE_NAME, valuesBucket)
  }

  // 更新一条物品
  async updateItem(item: Item): Promise<void> {
    if(!this.rdbStore) return;
    // 1. 创建查询语句实例：确定要更新的表格以及更新条件
    // 1. 只更新那些id和传进来的参数item的id相同的行
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME)
    predicates.equalTo('id',item.id)
    // 2. 数据库接口insert,update等只认valuesBucket.要把Item类打包成valuesBucket塞给数据库
    const valuesBucket:relationalStore.ValuesBucket = {
      id:item.id,
      name:item.name,
      location: item.location,
      count: item.count,
      category: item.category,
      note: item.note ?? ''
    }
    // 3. 更新数据库是异步操作
    await this.rdbStore.update(valuesBucket, predicates)
  }

  // 删除一条物品
  async deleteItem(id: string): Promise<void> {
    if(!this.rdbStore) return;
    // 1. 创建查询语句实例：确定要更新的表格以及更新条件
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME)
    predicates.equalTo('id', id)
    // 2. 更新数据库是异步操作
    await this.rdbStore.delete(predicates)
  }
}