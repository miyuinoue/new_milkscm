class Supermarket {
  IntList demand = new IntList();

  int order_quantity = 0;
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
    for (int i=0; i<7; i++) {
      this.demand.append(100);
    }
  }

  //需要予測して発注量決定
  int super_appdate(int inv, Supershelf supershelf) {
    this.demand.remove(0);
    this.demand.append(supershelf.sales_num);

    this.demand_forecast();
    this.standard_deviation();
    this.safty_stock();

    return order(inv, supershelf);//発注数計算
  }

  void demand_forecast() {
    float sum = 0;
    for (int i=0; i<7; i++) {
      sum += this.demand.get(i);
    }
    this.demand_forecast = sum/7;
  }

  void standard_deviation() {
    float var=0;
    for (int i=0; i<7; i++) {
      var+=(this.demand.get(i) - this.demand_forecast)*(this.demand.get(i) - this.demand_forecast);
    }
    this.standard_deviation = (float)Math.sqrt(var/(7-1));
  }

  void safty_stock() {
    saftystock_super = (int)Math.ceil(this.safety_factor * this.standard_deviation * Math.sqrt(this.leadtime +this.ordercycle));
  }

  //発注量o
  int order(int inv, Supershelf supershelf) {
    int capa = 0;
    int inv_sum = 0;
    int inv_plus = 0;

    //在庫は常に最低でも50個持っている状態にしたい//50でいいの？
    if (inv >= shelf_capacity) {
      inv_sum = inv - shelf_capacity;
    } else {
      inv_plus = shelf_capacity - inv;
    }

    order_quantity = (int)ceil((this.leadtime + this.ordercycle) * this.demand_forecast - inv_sum + saftystock_super);//発注量計算

    if (order_quantity < 0)order_quantity = 0;//発注量<0の時は0

    order_quantity = order_quantity + (inv_plus + supershelf.sales_loss);//既に在庫が50個以下だったら不足分も追加で発注する, 機会損失分も追加で発注する

    //空き容量との比較
    capa = (shelf_capacity + stock_capacity) - inv;//150-在庫
    if (capa < order_quantity)order_quantity = capa;

    return order_quantity;
  }

  //在庫量（5日sales_deadlineの在庫は一日の最後に廃棄になるのでカウントしない）
  int inventory(Superstock superstock, Supershelf supershelf) {
    int stockinv = 0;
    int shelfinv = 0;

    for (int i=superstock.stock(); i<superstock.size(); i++) {
      if (superstock.get(i).expiration == sales_deadline)continue;
      stockinv += superstock.get(i).size();
    }

    for (int i=supershelf.stock(); i<supershelf.size(); i++) {
      if (supershelf.get(i).expiration == sales_deadline)continue;
      shelfinv += supershelf.get(i).size();
    }

    return (stockinv + shelfinv);
  }


  void super_list() {
    ArrayList<Integer> list = new ArrayList<Integer>();

    list.add(day);//日にち
    list.add((int)this.demand_forecast);//需要予測
    list.add((int)this.standard_deviation);//標準偏差
    list.add(this.saftystock_super);//安全在庫
    list.add(this.order_quantity);//発注量

    super_list.add(list);
  }


  void addfile() {
    try {
      //PrintWriter file = new PrintWriter(new FileWriter(new File("/Users/miyuinoue/Desktop/milk_scm/scm_" + month() + "_" + day() +"/super/super_"+freshness+"_"+price+".csv"), true));
      PrintWriter file = new PrintWriter(new FileWriter(new File("C:\\Users\\miumi\\iCloudDrive\\Desktop\\milk_scm\\scm_"+ month() + "_" + day() +"\\super\\super_"+freshness+"_"+price+".csv"), true));

      file.println("");
      for (int i=0; i<7; i++) {
        file.print(",");
      }
      file.print(",");

      file.print("[SUPERSTOCK]");
      for (int i=0; i<18; i++) {
        file.print(",");
      }

      file.print("[SUPERSHELF]");


      file.println("");

      file.print("day"); 
      file.print(",");
      file.print("zyuyouyosoku");
      file.print(",");
      file.print("hyouzyunnhennsa");
      file.print(",");
      file.print("annzennzaiko");
      file.print(",");
      file.print("haxtyuu-ryo");
      file.print(",");  
              
      //superstock
      file.print(",");
      file.print("syoumikigenn");//14～
      for (int i=14; i>(sales_deadline-1); i--) {
        file.print(",");
      }
      file.print("nouhinn-ryo");
      file.print(",");
      file.print("shinadashi-ryo");
      for (int i=0; i<T; i++) {
        file.print(",");
      } 
      file.print("kikaisonnshitsu");
      file.print(",");
      //file.print("総品出し量");
      //file.print(",");
      file.print("haiki-ryo");
      file.print(",");
      file.print("total-haiki-ryo");
      file.print(",");

      //supershelf
      file.print(",");
      file.print("syoumikigenn");//14～5日
      for (int i=14; i>(sales_deadline-1); i--) {
        file.print(",");
      }
      file.print("shinadashi-ryo");//1期ごとの在庫量を出力する？
      file.print(",");
      file.print("raikyaku-su");
      for (int i=0; i<T; i++) {
        file.print(",");
      } 
      file.print("total-raikyaku-su");//在庫数をいれるべき？
      file.print(",");
      file.print("hanbai-su");
      file.print(",");
      file.print("kikaisonnshitsu");
      file.print(",");
      file.print("haiki-ryo");
      file.print(",");
      file.print("total-haiki-ryo");
      file.print(",");


      file.println("");

      for (int i=0; i<5; i++) {
        file.print(",");
      }
      //stock
      for (int i=14; i>(sales_deadline-1); i--) {
        file.print(",");
        file.print(i + "niti");
      }

      file.print(",");
      file.print(",");
      for (int i=0; i<T; i++) {
        file.print((i+1) + "ki"); 
        file.print(",");
      }
      file.print(",");
      file.print(",");
      file.print(",");

      //shelf
      for (int i=14; i>(sales_deadline-1); i--) {
        file.print(",");
        file.print(i + "niti");
      }
      file.print(",");
      file.print(",");
      for (int i=0; i<T; i++) {
        file.print((i+1) + "ki"); 
        file.print(",");
      }

      file.println("");

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

      file.println("");

      file.close();
    }
    catch (IOException e) {
      println(e);
      e.printStackTrace();
    }
  }
}
