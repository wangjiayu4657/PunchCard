import { Question } from '../models/Qustion'
import { AnswerState } from '../pages/HomePage'

/** 答案类型 */
enum AnswerType {
  /** 默认状态*/
  default,
  /** 正确状态 */
  right,
  /** 错误状态 */
  wrong
}

@Component
export default struct AnswerItem {
  //答案
  answer?:string
  //当前是否选中
  isSelected:boolean = false
  //回调
  callBack:(isSelected:boolean) => void = (isSelected:boolean) => {}
  //监听问题是否发生了改变
  @Link @Watch('questionChange') question:Question
  //答案类型
  @State answerType:AnswerType = AnswerType.default
  //答题状态
  @Prop answerState:AnswerState = AnswerState.stopped



  build() {
    Stack({alignContent: Alignment.Start}) {
      //选项按钮
      this.questionBtnBuilder()
      //答案类型标识图标
      this.maskIconBuilder()
    }
  }

  //选项按钮
  @Builder
  questionBtnBuilder() {
    Button(this.answer, {type: ButtonType.Normal})
      .width('80%')
      .height(44)
      .fontColor(this.answerType === AnswerType.default ? Color.Gray : Color.White)
      .backgroundColor(this.handlerAnswerTypeBgColor())
      .border({width: 1, color: this.answerType === AnswerType.default ? Color.Gray : Color.Transparent})
      .borderRadius(8)
      .onClick(() => {
        console.log('next question')
        if(this.answerState == AnswerState.running) {
          this.isSelected = !this.isSelected
        }
        this.callBack(this.isSelected)
      })
  }

  //答案类型标识图标
  @Builder
  maskIconBuilder() {
    Image(this.handlerAnswerTypeIcon())
      .width(20)
      .fillColor(Color.White)
      .offset({x: 10})
  }

  //处理获取答案类型标识图标
  handlerAnswerTypeIcon() {
    if(this.answerType === AnswerType.default) {
      return ''
    } else if(this.answerType === AnswerType.right) {
      return $r('app.media.ic_right')
    } else {
      return $r('app.media.ic_wrong')
    }
  }

  //处理获取背景色
  handlerAnswerTypeBgColor() : Color|ResourceStr {
    if(this.answerType === AnswerType.default) {
      return Color.Transparent
    } else if(this.answerType === AnswerType.right) {
      return '#1DBF7B'
    } else {
      return '#FA635F'
    }
  }

  //监听问题发生了改变
  questionChange() {
    console.log('question changed')
    if(this.answer === this.question.answer) {
      this.answerType = AnswerType.right
    } else {
      if(this.isSelected == true) {
        this.answerType = AnswerType.wrong
      } else {
        this.answerType = AnswerType.default
      }
    }
  }
}