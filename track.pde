class Track extends ArrayList <Milkstock> {

  Track() {
  }

  Track(int num) {
    for (int i=0; i<num; i++) {
      this.add(new Milkstock());
      this.get(this.size()-1).expiration = (E-i);
    }
  }

  void maker_addtrack(Milk milk) {//milkには賞味期限があるけどmilkstockには賞味期限がついてない
    for(int i=0; i<this.size(); i++){
      if(this.get(i).expiration == milk.expiration)this.get(i).add(milk);
    }
  }

  void super_addtrack(Milk milk) {
    for(int i=0; i<this.size(); i++){
      if(this.get(i).expiration == milk.expiration)this.get(i).add(milk);
    }
  }
}
