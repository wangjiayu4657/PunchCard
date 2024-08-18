import StatisticsItem from '../componets/StatisticsItem'
import { promptAction } from '@kit.ArkUI'
import { getRandomQuestions, Question } from '../models/Qustion'
import AnswerItem from '../componets/AnswerItem'

//答题状态
export enum AnswerState {
  /** 正在答题 */
  running,
  /** 暂停答题 */
  paused,
  /** 停止答题 */
  stopped,
}


@Entry
@Component
struct HomePage {
  //问题数据源
  questions:Question[] = getRandomQuestions(10)
  //时间控制器
  timeCtrl:TextTimerController = new TextTimerController()

  //问题索引, 用于开始下一题
  @State nextIdx:number = 0
  //当前选中的索引
  @State isSelected:boolean = false
  //答题状态
  @State answerState:AnswerState = AnswerState.stopped
  //获取当前选中的问题
  @State question:Question = this.questions[this.nextIdx]



  build() {
    Column({space: 20}) {
      //统计
      this.statisticsCardBuilder()

      //题目
      this.questionCardBuilder()

      //选项
      this.questionItemBuilder()

      //操作
      this.operationBuilder()
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM])
    .backgroundImage($r('app.media.img_practice_bg'))
  }

  //统计组件
  @Builder
  statisticsCardBuilder() {
    Column({space: 15}) {
      //统计选相卡
      StatisticsItem({
        name:'准确率',
        icon: $r('app.media.ic_accuracy'),
      }){
        Text('0%')
          .width(100)
          .textAlign(TextAlign.Center)
      }

      StatisticsItem({
        name:'进度',
        icon: $r('app.media.ic_progress'),
      }){
        Progress({value: 0, total: 100})
          .width(100)
      }

      StatisticsItem({
        name:'个数',
        icon: $r('app.media.ic_count'),
      }){
        Button('10')
          .width(100)
          .height(25)
          .backgroundColor('#EBEBEB')
          .fontColor(Color.Black)
      }

      StatisticsItem({
        name:'用时',
        icon: $r('app.media.ic_timer'),
      }){
        Row(){
          TextTimer({controller:this.timeCtrl})
            .onTimer( (utc: number, elapsedTime: number) => {
              console.log('utc ==', utc)
              console.log('elapsedTime == ', elapsedTime)
            })
        }
        .width(100)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('90%')
    .borderRadius(8)
    .backgroundColor(Color.White)
    .padding(15)
    .margin({top: 10})
  }


  //问题组件
  @Builder
  questionCardBuilder() {
    Column({space: 10}) {
      Text(this.questions[this.nextIdx].word)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Text(this.questions[this.nextIdx].sentence)
        .fontSize(14)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .padding(15)
  }

  //问题选项组件
  @Builder
  questionItemBuilder() {
    Column({space: 15}) {
      ForEach(
        this.questions[this.nextIdx].options,
        (answer:string) => {
          AnswerItem({
            isSelected:this.isSelected,
            answer:answer,
            answerState:this.answerState,
            question: $question,
            callBack: (isSelected:boolean) => {
              this.handlerSelQuestion(isSelected)
            }
          }
        )
      },(answer:string) => answer + this.questions[this.nextIdx].options)
    }
    .width('100%')
  }

  //操作组件
  @Builder
  operationBuilder() {
    Row() {
      Button('结束测试')
        .btnStyle({
          bgColor: Color.Transparent,
          fontColor: this.answerState === AnswerState.stopped ? Color.Gray : Color.Black,
          bordColor: this.answerState === AnswerState.stopped ? Color.Gray : Color.Black
        })
        .enabled(this.answerState !== AnswerState.stopped)
        .onClick(() => {
          this.answerState = AnswerState.stopped
        })

      Button(this.answerState === AnswerState.running ? '暂停测试' : '开始测试')
        .btnStyle({
          bgColor: this.answerState == AnswerState.running ? '#555555' : Color.Black,
          fontColor: Color.White,
          bordColor: this.answerState == AnswerState.running ? '#555555' : Color.Black,
        })
        .onClick(() => {
          if(this.answerState == AnswerState.running) {
            this.answerState = AnswerState.paused
          } else {
            this.answerState = AnswerState.running
          }
        })
    }
    .width('100%')
    .margin({top: 10})
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  //处理点击选择答题选项
  handlerSelQuestion(isSelected:boolean) {
    if(this.answerState != AnswerState.running) {
      promptAction.showToast({message: '请先点击开始测试'})
      this.isSelected = false
      return
    }

    //开启计时
    this.timeCtrl.start()

    //当前选中的选项
    this.isSelected = isSelected
    //获取当前选中的问题
    this.question = this.questions[this.nextIdx]

    if(this.nextIdx < this.questions.length) {
       setTimeout(() => {
         this.nextIdx += 1
         //重置下一题的选中状态
         this.isSelected = false
       }, 1000)
    }

    console.log('selIdx == ',this.nextIdx)
  }


}


interface BtnColor {
  bgColor: ResourceStr | Color;
  fontColor: ResourceStr | Color;
  bordColor: ResourceStr | Color;
}

@Extend(Button)
function btnStyle(color: BtnColor) {
  .width(100)
  .height(40)
  .type(ButtonType.Capsule)
  .border({width: 1, color:color.bordColor})
  .backgroundColor(color.bgColor)
  .fontColor(color.fontColor)
}

