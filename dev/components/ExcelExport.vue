<template>
<a class="excel">
    <img v-bind:src="iconImage">
</a>
</template>

<script>
import GridComponentMixin from "./GridComponentMixin.vue";
export default {
    mixins: [GridComponentMixin],
    computed: {
        iconImage() {
            return `${this.$foswiki.getPubUrl()}/System/SearchGridPlugin/excel_logo.png`;
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