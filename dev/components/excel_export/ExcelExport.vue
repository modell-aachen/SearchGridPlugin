<template>
<a class="excel" v-bind:title="tooltip" @click="exportToExcel()">
    <img v-bind:src="iconImage">
</a>
</template>

<script>
import MaketextMixin from "../MaketextMixin.vue";
import FieldRenderer from "./FieldRenderer.js"
export default {
    mixins: [MaketextMixin],
    props: ["fields"],
    computed: {
        iconImage() {
            return `${this.$foswiki.getPubUrl()}/System/SearchGridPlugin/excel_logo.png`;
        },
        tooltip() {
            return this.maketext("Export all elements based on the current filter settings.")
        },
        fieldsToExport() {
            return  this.fields.filter((field) => {
                return FieldRenderer.supportsFieldRendering(field.component);
            });
        }
    },
    methods: {
        getEntriesToExport() {
            let params = this.$parent.getSearchQueryRequestParameters();
            params.rows = 2147483647;
            params.start = 0;

            return this.$ajax({
              type: "POST",
              headers: { 'X-HTTP-Method-Override': 'GET' },
              url: this.$foswiki.getScriptUrl('rest', 'SearchGridPlugin', 'searchproxy'),
              traditional: true,
              data: params
            })
            .then((result) => {
                result = JSON.parse(result);
                return result.response.docs;
            });
        },
        convertDocumentsToExcelExportPluginFormat(solrDocuments) {
            //The format we need to achieve:
            //[["Header1", "Header2",...],[Row1Value1,Row1Value2,...],...]

            let renderedHeaders = this.fieldsToExport.map((field) =>{
                return field.title;
            });

            let renderedDocuments = [];
            for(let solrDocument of solrDocuments){
                let renderedDocument = [];
                for(let field of this.fieldsToExport){
                    renderedDocument.push(FieldRenderer.renderFieldForDocument(solrDocument, field));
                }
                renderedDocuments.push(renderedDocument);
            }

            return [renderedHeaders].concat(renderedDocuments);
        },
        exportToExcel() {
            this.getEntriesToExport()
            .then((results) => {
                let data = this.convertDocumentsToExcelExportPluginFormat(results);
                let exportRequestData = {
                    web: this.$foswiki.preferences.WEB,
                    topic: this.$foswiki.preferences.TOPIC,
                    header: this.fieldsToExport.length,
                    data: data
                };

                return this.$ajax({
                  type: "POST",
                  url: this.$foswiki.getScriptUrl('restauth', 'ExportExcelPlugin', 'export'),
                  traditional: true,
                  data: {payload: JSON.stringify(exportRequestData)}
                })
            })
            .then((downloadUrl) => {
                this.downloadExcelFile(downloadUrl);
            });

        },
        downloadExcelFile(downloadUrl) {
            window.location.href = downloadUrl;
        }
    }
}
</script>

<style lang="scss">
.excel {
    cursor: pointer;
    img {
        height: 40px;
    }
}
</style>