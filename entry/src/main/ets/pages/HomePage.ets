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
  //题目总数量
  @State totalCount:number = 10
  //问题索引, 用于开始下一题
  @State nextIdx: number = 0
  //当前选中的索引
  @State isSelected: boolean = false
  //答题状态
  @State answerState: AnswerState = AnswerState.stopped
  //问题数据源
  @State questions: Question[] = getRandomQuestions(10)
  //获取当前选中的问题
  @State question: Question = this.questions[this.nextIdx]
  //记录答对的题目数量
  rightCount:number = 0
  //答题准确率
  @State accuracy: number = 0

  //时间控制器
  timeCtrl: TextTimerController = new TextTimerController()
  //答题数量输入弹窗
  dialogCtrl:CustomDialogController = new CustomDialogController({
    builder: InputDialog({
      count: this.totalCount.toString(),
      confirm: (count:string) => {
        this.reset(count)
      }
    }),
    autoCancel: true,
    customStyle: true,
  })

  build() {
    Column({ space: 20 }) {
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
    Column({ space: 15 }) {
      //统计选相卡
      StatisticsItem({
        name: '准确率',
        icon: $r('app.media.ic_accuracy'),
      }) {
        Text(`${(this.accuracy * 100).toFixed(2)} %`)
          .width(100)
          .textAlign(TextAlign.Center)
      }

      StatisticsItem({
        name: '进度',
        icon: $r('app.media.ic_progress'),
      }) {
        Progress({ value: this.nextIdx, total: this.totalCount })
          .width(100)
          .color(Color.Blue)
      }

      StatisticsItem({
        name: '个数',
        icon: $r('app.media.ic_count'),
      }) {
        Button(this.totalCount.toString())
          .width(100)
          .height(25)
          .backgroundColor('#EBEBEB')
          .fontColor(Color.Black)
          .onClick(() => {
            this.dialogCtrl.open()
          })
      }

      StatisticsItem({
        name: '用时',
        icon: $r('app.media.ic_timer'),
      }) {
        Row() {
          TextTimer({ controller: this.timeCtrl })
            // .onTimer((utc: number, elapsedTime: number) => {
            //   console.log('utc ==', utc)
            //   console.log('elapsedTime == ', elapsedTime)
            // })
        }
        .width(100)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('90%')
    .borderRadius(8)
    .backgroundColor(Color.White)
    .padding(15)
    .margin({ top: 10 })
  }

  //问题组件
  @Builder
  questionCardBuilder() {
    Column({ space: 10 }) {
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
    Column({ space: 15 }) {
      ForEach(
        this.questions[this.nextIdx].options,
        (answer: string) => {
          AnswerItem({
            isSelected: this.isSelected,
            answer: answer,
            answerState: this.answerState,
            question: $question,
            callBack: (isSelected: boolean, answer?:string) => {
              this.handlerSelQuestion(isSelected, answer)
            }
          }
          )
        }, (answer: string) => answer + this.questions[this.nextIdx].options)
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
        .onClick(() => this.stopAnswer())

      Button(this.answerState === AnswerState.running ? '暂停测试' : '开始测试')
        .btnStyle({
          bgColor: this.answerState == AnswerState.running ? '#555555' : Color.Black,
          fontColor: Color.White,
          bordColor: this.answerState == AnswerState.running ? '#555555' : Color.Black,
        })
        .onClick(() => {
          if (this.answerState == AnswerState.running) {
            this.pauseAnswer()
          } else {
            this.startAnswer()
          }
        })
    }
    .width('100%')
    .margin({ top: 10 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  //处理点击选择答题选项
  handlerSelQuestion(isSelected: boolean, answer?:string) {
    if (this.answerState != AnswerState.running) {
      promptAction.showToast({ message: '请先点击开始测试' })
      this.isSelected = false
      return
    }

    this.timeCtrl.start()

    //当前选中的选项
    this.isSelected = isSelected
    //获取当前选中的问题
    this.question = this.questions[this.nextIdx]

    if(this.question.answer === answer) {
      this.rightCount++
    }

    if (this.nextIdx < this.questions.length) {
      setTimeout(() => {
        this.nextIdx += 1
        //重置下一题的选中状态
        this.isSelected = false
        this.accuracy = this.rightCount / this.nextIdx
      }, 1000)
    }

    console.log('selIdx == ', this.nextIdx)
  }

  //开始答题
  startAnswer() {
    if (this.answerState == AnswerState.running) {
      this.timeCtrl.pause()
      this.answerState = AnswerState.paused
    } else {
      //开启计时
      this.timeCtrl.start()
      this.answerState = AnswerState.running
    }
  }

  //暂停答题
  pauseAnswer() {
    this.timeCtrl.pause()
    this.answerState = AnswerState.paused
  }

  //结束答题
  stopAnswer() {
    this.timeCtrl.reset()
    this.answerState = AnswerState.stopped
  }

  //重新选择答题数量时需要重置
  reset(count:string) {
    this.nextIdx = 0
    this.totalCount = parseInt(count)
    this.questions = getRandomQuestions(this.totalCount)
  }


}


// @Preview
@CustomDialog
struct InputDialog {
  count:string = '0'
  confirm?: (count:string) => void
  ctrl?: CustomDialogController

  build() {
    Column({ space: 15 }) {
      //标题
      Text('请输入数量')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      //输入框
      TextInput({ text: this.count, placeholder: '请输入答题数量' })
        .onChange((count: string) => this.count = count)
        .type(InputType.Number)

      //操作按钮
      Row({ space: 30 }) {
        Button('取消')
          .width(100)
          .backgroundColor(Color.Gray)
          .onClick(() => {
            this.ctrl?.close()
          })

        Button('确定')
          .width(100)
          .backgroundColor(Color.Green)
          .onClick(() => {
            this.confirm ? this.confirm(this.count) : null
            this.ctrl?.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('90%')
    .padding(15)
    .borderRadius(8)
    .backgroundColor(Color.White)
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
  .border({ width: 1, color: color.bordColor })
  .backgroundColor(color.bgColor)
  .fontColor(color.fontColor)
}



/*
@CustomDialog
struct InputPicker {
  count:string = '0'
  ctrl?: CustomDialogController
  build() {
    Column() {
      TextPicker({
        range: ['5', '10', '15', '20'],
        value: this.count
      })
        .canLoop(false)
        .onChange((value: string | string[], index: number | number[]) => {
          console.log(`value == ${value}  idx: == ${index}`)
        })

      //操作按钮
      Row({ space: 30 }) {
        Button('取消')
          .width(100)
          .backgroundColor(Color.Gray)
          .onClick(() => {
            this.ctrl?.close()
          })

        Button('确定')
          .width(100)
          .backgroundColor(Color.Green)
          .onClick(() => {
            this.ctrl?.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
  }
}
*/