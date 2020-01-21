class Supermarket {
  IntList demand = new IntList();
  int section = 7;//移動平均期間

  int order_quantity = 0;
  int total_order_quantity = 0;
  float standard_deviation = 0;
  float demand_forecast = 0;
  float safety_factor = 1.65;
  int saftystock_super=0;
  int leadtime = 0;
  int ordercycle = 1;

  Supermarket() {
  }

  void super_first() {
    this.demand.clear();
    for (int i=0; i<this.section; i++) {
      this.demand.append(100);
    }
  }

  void reset() {
    total_order_quantity = 0;
  }

  //需要予測して発注量決定
  int super_appdate(int inv, int salesnum) {
    //int super_appdate(int inv, int customernum) {
    this.demand.remove(0);
    this.demand.append(salesnum);//スーパーに来店する人はみんな牛乳を買いたいと思っている人たち

    this.demand_forecast();
    this.standard_deviation();
    this.safty_stock();

    //return order(inv, supershelf);//発注数計算
    return order(inv);//発注数計算
  }

  void demand_forecast() {
    float sum = 0;
    for (int i=0; i<this.section; i++) {
      sum += this.demand.get(i);
    }
    this.demand_forecast = sum/this.section;
  }

  void standard_deviation() {
    float var=0;
    for (int i=0; i<this.section; i++) {
      var+=(this.demand.get(i) - this.demand_forecast)*(this.demand.get(i) - this.demand_forecast);
    }
    this.standard_deviation = (float)Math.sqrt(var/(this.section-1));
  }

  void safty_stock() {
    saftystock_super = (int)Math.ceil(this.safety_factor * this.standard_deviation * Math.sqrt(this.leadtime +this.ordercycle));
  }


  //発注量o
  int order(int inv) {
    int capa = 0;
    int inv_plus = 0;
    int inv_minus = 0;
    int num = shelf_capacity + 100;

    //在庫は常に最低でも200個持っている状態にしたい//棚出し3回分は，保持しておきたい
    if (inv >= num) {
      inv_plus = inv - num;
    } else {
      inv_minus = num - inv;
    }

    order_quantity = (int)ceil((this.leadtime + this.ordercycle) * this.demand_forecast - inv_plus + saftystock_super) + inv_minus;//発注量計算
    if (order_quantity < 0)order_quantity = 0;//発注量<0の時は0

    //空き容量との比較
    capa = (shelf_capacity + stock_capacity) - inv;//600-在庫
    if (capa < order_quantity)order_quantity = capa;

    total_order_quantity += order_quantity;
    return order_quantity;
  }

  //在庫量（5日sales_deadlineの在庫は一日の最後に廃棄になるのでカウントしない）
  int inventory(Superstock superstock, Supershelf supershelf) {
    int stockinv = 0;
    int shelfinv = 0;

    int s=0;

    for (int i=0; i<superstock.size(); i++) {
      if (superstock.get(i).expiration == sales_deadline)s+=superstock.get(i).size();

      if (superstock.get(i).expiration <= sales_deadline)continue;
      stockinv += superstock.get(i).size();
      //if (superstock.get(i).expiration <= 1)println("day:" + day + "  stockinv:" + superstock.get(i).expiration + "日");//println
    }

    for (int i=0; i<supershelf.size(); i++) {
      if (supershelf.get(i).expiration == sales_deadline)s+=supershelf.get(i).size();

      if (supershelf.get(i).expiration <= sales_deadline)continue;
      shelfinv += supershelf.get(i).size();

      //if (supershelf.get(i).expiration <= 1)println("day:" + day + "  shelfinv:" + supershelf.get(i).expiration + "日");//println
    }


    return (stockinv + shelfinv);
  }

  float loss_ritsu(int stockwaste, int shelfwaste) {
    float uriage = kakaku * supershelf.total_sales_num;
    float losskinngaku = kakaku * (stockwaste + shelfwaste) + supershelf.waribiki_profit;

    float lossritsu = losskinngaku/uriage * 100;
    return lossritsu;
  }


  void super_list() {
    ArrayList<Integer> list = new ArrayList<Integer>();

    list.add(day-60);//日にち
    list.add((int)this.demand_forecast);//需要予測
    list.add((int)this.standard_deviation);//標準偏差
    list.add(this.saftystock_super);//安全在庫
    list.add(this.order_quantity);//発注量
    list.add(this.total_order_quantity);//総発注量

    super_list.add(list);
  }

  void newfile() {
    try {
      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/"+sales_deadline+"_"+delivery_deadline+"/super/super"+beta_f+"_"+beta_p+".csv")));
      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\卒研\\milk_scm\\scm_"+ month() + "_" + day() +"\\"+sales_deadline+"_"+delivery_deadline+"\\super\\super"+beta_f+"_"+beta_p+"_"+kawanai+".csv"), true));//！！！

      file.println("");
      file.print("freshness");      
      file.print(",");
      file.print(freshness);
      file.println("");
      file.print("price");      
      file.print(",");
      file.print(price);
      file.println("");
      file.println("");

      file.print("day"); 
      file.print(",");
      file.print("zyuyouyosoku");
      file.print(",");
      file.print("hyouzyunnhennsa");
      file.print(",");
      file.print("annzennzaiko");
      file.print(",");
      file.print("haxtyuuryo");
      file.print(","); 
      file.print("totalhaxtyuuryo");
      file.print(",");

      //superstock
      file.print(",");
      for (int i=14; i>(sales_deadline-1); i--) {
        file.print(i + "niti");
        file.print(",");
      }
      file.print("nouhinnryo");
      file.print(",");
      file.print("totalnouhinnryo");
      file.print(",");
      for (int i=0; i<T; i++) {
        file.print("shinadashi" + (i+1) + "ki"); 
        file.print(",");
      }
      file.print("kikaisonnshitsu");
      file.print(",");
      file.print("totalkikaisonnshitsu");
      file.print(",");
      file.print("haikiryo");
      file.print(",");
      file.print("totalhaikiryo");
      file.print(",");

      //supershelf
      file.print(",");
      for (int i=14; i>(sales_deadline-1); i--) {
        file.print(i + "niti");
        file.print(",");
      }
      file.print("shinadashiryo");//1期ごとの在庫量を出力する？
      file.print(",");
      for (int i=0; i<T; i++) {
        file.print("kyaku" + (i+1) + "ki"); 
        file.print(",");
      }
      file.print("totalraikyakusu");//在庫数をいれるべき？
      file.print(",");
      file.print("hanbaisu");
      file.print(",");
      file.print("totalhanbaisu");
      file.print(",");
      file.print("kikaisonnshitsu");
      file.print(",");
      file.print("totalkikaisonnshitsu");
      file.print(",");
      file.print("kawanai");
      file.print(",");
      file.print("haikiryo");
      file.print(",");
      file.print("totalhaikiryo");
      file.print(",");

      file.println("");
      file.close();
    }
    catch (IOException e) {
      println(e);
      e.printStackTrace();
    }
  }


  void addfile() {
    try {
      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/inouemiyu/Desktop/milk_scm/scm_" + month() + "_" + day() +"/"+sales_deadline+"_"+delivery_deadline+"/super/super"+beta_f+"_"+beta_p+".csv"), true));
      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\卒研\\milk_scm\\scm_"+ month() + "_" + day() +"\\"+sales_deadline+"_"+delivery_deadline+"\\super\\super"+beta_f+"_"+beta_p+"_"+kawanai+".csv"), true));//！！！

      for (int i=0; i<super_list.size(); i++) {
        for (int j=0; j<super_list.get(i).size(); j++) {
          file.print(super_list.get(i).get(j));
          file.print(",");
        }
        file.print(",");

        for (int k=0; k<stock_list.get(i).size(); k++) {
          file.print(stock_list.get(i).get(k));
          file.print(",");
        }  
        file.print(",");

        for (int l=0; l<shelf_list.get(i).size(); l++) {
          file.print(shelf_list.get(i).get(l));
          file.print(",");
        }
        file.println("");
      }

      file.close();
    }
    catch (IOException e) {
      println(e);
      e.printStackTrace();
    }
  }
}
