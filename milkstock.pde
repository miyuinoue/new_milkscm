class Milkstock extends ArrayList <Milk> {
  int expiration;

  Milkstock() {
  }

  //賞味期限の変更
  void daychange() {
    this.expiration--;

    for (int i=0; i<this.size(); i++) {
      this.get(i).daychange();
    }
  }

  //新しいmilkを作る
  void makemilk(int p) {
    for (int i=0; i<p; i++) {
      this.add(new Milk());
      this.get(this.size()-1).newmilk();
    }

    this.expiration = E;
  }

  //num日（販売・納品期限）と賞味期限が一緒の場合は廃棄
  int waste(int num) {
    int waste_size = 0;
    if (this.size() == 0)return 0;

    if (this.expiration == num) {      
      waste_size = this.size();
    }

    return waste_size;
  }

  //牛乳の販売価格の設定
  void price(int p) {
    for (int i=0; i<this.size(); i++) {
      this.get(i).price = p;
    }
  }

  void notbuy_milk() {
    this.add(new Milk());
    this.get(this.size()-1).notbuymilk();
  }
}
