class Supershelf extends ArrayList <Milkstock> {
  int restocknum;
  int sales_loss = 0;
  int sales_num = 0;
  int visitors = 0;
  int shelf_waste;
  int shelf_totalwaste = 0;

  Supershelf() {
  }

  //日付が変わると賞味期限が-1日される
  void shelf_daychange() {
    for (int i=0; i < this.size(); i++) {
      this.get(i).daychange();
    }
    visitors = 0;
    sales_num = 0;
    sales_loss = 0;
  }

  //在庫量
  int inventory() {
    int inv = 0;
    for (int i=this.stock(); i<this.size(); i++) {
      inv += this.get(i).size();
    }

    return inv;
  }

  //補充数（shelfの最大在庫量 - shelfの現在の在庫量）
  int restock() {
    return shelf_capacity - this.inventory();
  }

  //在庫の牛乳が何番目からか
  int stock() {
    int exp = this.size();

    for (int i=0; i<this.size(); i++) {
      if (this.get(i).size() == 0)continue;

      if (this.get(i).expiration >= sales_deadline) {
        exp = i;
        break;
      }
    }
    return exp;
  }

  //前期に足らなかった牛乳を補充する
  void unloading(SuperTrack supertrack) {    
    restocknum = 0;//品出しした量

    int i = supertrack.size()-1;

    for (int j=0; j<supertrack.get(i).size(); j++) {
      boolean noExpiration = true;
      if (supertrack.get(i).get(j).size() == 0)continue;


      //納品された牛乳の賞味期限日数と同じ牛乳がstockにある場合
      int e = supertrack.get(i).get(j).expiration;

      for (int l=0; l<this.size(); l++) {
        if (e == this.get(l).expiration) {
          noExpiration = false;
          this.get(l).addAll(supertrack.get(i).get(j));
          restocknum += supertrack.get(i).get(j).size();
        }
      }

      //納品された牛乳の賞味期限日数と同じ牛乳がstockにない場合 or スーパーの倉庫が空の場合
      if (noExpiration == true || this.size() == 0) {
        this.add(supertrack.get(i).get(j));
        restocknum += supertrack.get(i).get(j).size();
      }
    }
  }

  //販売
  void sales(int c) {
    this.visitors++;
    if (this.inventory() == 0) {
      sales_loss++;
      return;
    }

    //買わないを選択した人（c番目＝買わない・(this.inventories()-1)+1番目が買わない選択肢）
    if (c == this.inventory()) { 
      buy.get(buy.size()-1).notbuy_milk();
      return;
    }

    for (int i=this.stock(); i<this.size(); i++) {
      for (int j=0; j<this.get(i).size(); j++) {
        c--;
        if (c == 0) {
          buy.get(buy.size()-1).add(this.get(i).remove(j));
          sales_num++;
        }
      }
    }
  }

  //販売期限を過ぎた牛乳を廃棄する
  void waste() {
    shelf_waste = 0;
    for (int i=0; i<this.size(); i++) {
      shelf_waste += this.get(i).waste(sales_deadline);
    }

    shelf_totalwaste += shelf_waste;
  }

  //賞味期限が残り3日になったら3割引きする
  void discount3(int d) {
    for (int i=0; i<this.size(); i++) {
      if (this.get(i).expiration != 5 & this.get(i).expiration != 6 & (this.get(i).expiration != 7)) {
        continue;
      } else {
        for (int j=0; j<this.get(i).size(); j++) {
          this.get(i).get(j).price = d;
        }
      }
    }
  }

  void shelf_list(Customer customer) {
    ArrayList<Integer> list = new ArrayList<Integer>();

    //賞味期限ごとの在庫量
    for (int i=14; i>=sales_deadline; i--) {
      boolean sh = false;
      for (int j=0; j<this.size(); j++) {

        if (this.get(j).expiration == i) {
          list.add(this.get(j).size());
          sh = true;
        }
      }
      if (sh == false) {
        list.add(0);
      }
    }
    list.add(this.restocknum);//品出し納品量
    //来客数    
    for (int i=0; i<customer.customernum.size(); i++) {
      list.add(customer.customernum.get(i));
    }
    list.add(customer.customertotal);//総来客数

    list.add(this.sales_num);//販売数
    list.add(this.sales_loss);//機会損失
    list.add(this.shelf_waste);//廃棄量
    list.add(this.shelf_totalwaste);//総廃棄量

    shelf_list.add(list);
  }
}