<template>
<a class="excel" v-bind:title="tooltip">
    <img v-bind:src="iconImage">
</a>
</template>

<script>
import GridComponentMixin from "./GridComponentMixin.vue";
import MaketextMixin from "./MaketextMixin.vue";
export default {
    mixins: [GridComponentMixin, MaketextMixin],
    computed: {
        iconImage() {
            return `${this.$foswiki.getPubUrl()}/System/SearchGridPlugin/excel_logo.png`;
        },
        tooltip() {
            return this.maketext("Export all elements based on the current filter settings.")
        }
    }
}
</script>

<style lang="sass">
.excel {
    cursor: pointer;
    img {
        height: 40px;
    }
}
</style>