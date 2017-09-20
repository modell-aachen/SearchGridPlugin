<template>
<td>
    <div class='ampel'>
        <div class='signal'>
            <span v-if="showDate && ampel.warnStatus != 'none'">{{ampel.dueDate}}</span>
            <img v-tooltip="tooltip" :src="url">
        </div>
        <div class='text'>
        </div>
    </div>
</td>
</template>

<script>
import MaketextMixin from "../MaketextMixin.vue"
export default {
    mixins: [MaketextMixin],
    props: ['doc','params'],
    /* params:
        datefield
        show_date (optional)
        warning_days_yellow (optional) 
        warning_days_red (optional)
    */
    data() {
        let statusImageMap = {
            red: "ampel_r.png",
            green: "ampel_g.png",
            yellow: "ampel_o.png",
            none: "ampel.png"
        }
        let showDate = (this.params[1])?((this.params[1]==0)?false:true):false;
        let warnTimeY = (this.params[2])?parseInt(this.params[2]):7;
        let warnTimeR = (this.params[3])?parseInt(this.params[3]):-1;
        let date = this.doc[this.params[0]];
        let now = this.$moment();

        let dueDate = this.$moment(date);
        let daysRemaining = Math.ceil(dueDate.diff(now,'days',true));
        let warnStatus;
        if(!date || !dueDate.isValid() || this.$moment(dueDate).format('X') === "0"){
            warnStatus = "none";
        }
        else if (daysRemaining <= warnTimeR){
            warnStatus = "red"
        }
        else if(daysRemaining < warnTimeY){
            warnStatus = "yellow"
        }
        else{
            warnStatus = "green";
        }
        let diffDate = warnStatus === "none" ? "" : now.startOf('day').to(dueDate);
        let ampel = {
            dueDate: dueDate.format("D.MM.YYYY"),
            daysRemaining: daysRemaining,
            diffDate: diffDate,
            warnStatus: warnStatus,
            statusImage: statusImageMap[warnStatus]
        }
        return {
            ampel: ampel,
            showDate: showDate,
            foswiki: this.$foswiki
        }
    },
    computed: {
        url(){
            return this.foswiki.preferences.PUBURL+'/System/AmpelPlugin/images/'+this.ampel.statusImage;
        },
        tooltip(){
            console.log(this.ampel.daysRemaining);
            let positivDaysRemaining = this.ampel.daysRemaining;
            if (this.ampel.warnStatus != 'none'){
                let text ='([_1]) still [_2] days';
                if(this.ampel.daysRemaining == 1) text = '([_1]) still one day';
                if(this.ampel.daysRemaining == 0) text = '([_1]) today';
                if(this.ampel.daysRemaining == -1) text = '([_1]) since one day';
                if(this.ampel.daysRemaining < -1){
                    positivDaysRemaining = positivDaysRemaining * (-1);
                    text = '([_1]) since [_2] days';
                }
                return this.maketext(text,[this.$moment(this.ampel.dueDate, "DD.MM.YYYY").add(this.ampel.daysRemaining, 'days').format('D.MM.YYYY'), positivDaysRemaining]);
            }else{
                return "";
            }
        }
    }
}
</script>
<style type="sass">
.signal {
    text-align: center;
}
.tooltip {
  border: 1px solid #e0e0e0;
  display: block !important;
  padding: 4px;
  z-index: 10000;
  background: white;

  .tooltip-inner {
    color: #8d8d8d;
    border-radius: 16px;
    padding: 5px 10px 4px;
  }

  .tooltip-arrow {
    display: block;
  }
}
.tooltip[aria-hidden='true'] {
  visibility: hidden;
  opacity: 0;
  transition: opacity .15s, visibility .15s;
}

.tooltip[aria-hidden='false'] {
  visibility: visible;
  opacity: 1;
  transition: opacity .15s;
}
</style>
