<template>
    <div class="test-grid-field">
        <ul>
            <li v-for="param in params" :key="param">{{doc[param]}}</li>
        </ul>
    </div>
</template>

<script>
export default {
    props: ['doc','params']
}
</script>

<style lang="scss">
.test-grid-field {
  margin: 5px;
  border: solid 1px black;
  background-color: lightgray;
  overflow: hidden;
}
</style>
