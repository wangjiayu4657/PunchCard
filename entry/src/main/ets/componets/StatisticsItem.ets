
@Component
export default struct StatisticsItem {
  //图标
  icon?:ResourceStr
  //名称
  name?:ResourceStr
  //字体颜色
  fontColor?:ResourceStr | Color = Color.Gray
  //末尾组件
  @BuilderParam tailBuilder: () => void = this.defaultBuilder

  @Builder defaultBuilder() {
    Text('--')
  }

  build() {
    Row({space: 10}) {
      Image(this.icon)
        .height(14)
        .width(14)

      Text(this.name)
        .fontWeight(FontWeight.Medium)
        .fontSize(14)
        .fontColor(this.fontColor)

      Blank()
      this.tailBuilder()
    }
    .width('100%')
  }
}