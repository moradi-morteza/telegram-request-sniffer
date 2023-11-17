Vue.use(VueJsonPretty)
Vue.use(VueBottomSheet);

new Vue({
    el: '#app',
    data: {
        requestJsonContainer: "",
        responseJsonContainer: "",
        showSheet: false,
        messageTypeFilter: "all",
        query: "",
        hold: false,
        clientId: "",
        messages: []
    },
    methods: {
        getTypeBadge(type) {
            if (type === "RESPONSE") {
                return 'badge bg-success';
            }
            if (type === "REQUEST") {
                return 'badge bg-primary';
            }
            if (type === "Server") {
                return 'badge bg-warning';
            }
            if (type === "ERROR") {
                return 'badge bg-danger';
            }
        },
        clearClass(className) {
            return className;
        },
        showJson(jsonObject) {
            let token = jsonObject.TOKEN;
            let type = jsonObject.TYPE;

            // if (type==="Request"){
            // set data to Json bottomSheet
            const requestView = document.getElementById("requestView")
            requestView.innerHTML = "";
            const requestViewEditor = new JSONEditor(requestView)
            requestViewEditor.set(jsonObject)
            this.requestJsonContainer = jsonObject;

            // find response if exist
            let responseJsons = this.messages.filter(item => {
                return item.TOKEN === token && item.TYPE === "RESPONSE";
            })
            if (responseJsons !== null && responseJsons.length > 0) {
                // create the editor
                const responseView = document.getElementById("responseView")
                responseView.innerHTML = "";
                this.responseJsonContainer = responseJsons;
                responseJsons.forEach(responseJson => {
                    const responseViewEditor = new JSONEditor(responseView)
                    responseViewEditor.set(responseJson)
                })
            }else{
                const responseView = document.getElementById("responseView")
                responseView.innerHTML = "";
            }


            // get json
            this.$refs.myBottomSheet.open();

        },
        exportMessages() {
            if (this.messages.length === 0) {
                alert("There is no data!")
                return;
            }
            const data = JSON.stringify(this.messages)
            var element = document.createElement('a');
            element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(data));
            element.setAttribute('download', "export.json");
            element.style.display = 'none';
            document.body.appendChild(element);
            element.click();
            document.body.removeChild(element);
        },
        clearMessages() {
            this.messages = []
        },
        handleFileSelect(event) {
            const file = event.target.files[0];
            const reader = new FileReader();

            reader.onload = () => {
                const content = reader.result;
                // Convert file content to JSON array
                const jsonArray = JSON.parse(content);
                this.messages = jsonArray;
            };

            reader.readAsText(file);
        },
        importMessages() {
            this.$refs.fileInput.click();
        },
        close() {
            this.$refs.myBottomSheet.close();
        },
        getScreenWidth() {
            return (screen.width - 200) + "px"
        },
        copyToClipboard(object) {
            const type = 'text/plain';
            const blob = new Blob([JSON.stringify(object)], {type});
            const data = [new ClipboardItem({[type]: blob})];
            navigator.clipboard.write(data).then(function () {
                alert('Copied to Clipboard')
            }, function () {
                console.log('Failed to copy to clipboard.');
            });

        },
        deleteItem(item) {
            const index = this.messages.indexOf(item);
            this.$delete(this.messages, index)
        },
        handelCheckboxChange(index) {

        }
    },
    mounted() {
        var urlLocal =  "ws://localhost:3000/ws"
        const socket = new WebSocket(urlLocal);
        socket.addEventListener('message', (event) => {
            const message = event.data;
            let jsonObject = JSON.parse(message)
            if (!this.hold && this.clientId && this.clientId===jsonObject.CLIENTID){
                this.messages.push(jsonObject);
            }
        });
    },
    created() {
        this.clientId = localStorage.getItem('clientId') || "";
        this.messageTypeFilter = localStorage.getItem('messageTypeFilter') || "all";
    },
    computed: {
        filteredData() {

            let filteredMessages = this.messages;

            if (this.messageTypeFilter !== 'all') {
                filteredMessages = filteredMessages.filter(
                    message => message.TYPE === this.messageTypeFilter
                );
            }
            return filteredMessages;
        },
    },
    watch: {
        clientId(newVal) {
            localStorage.setItem('clientId', newVal);
        },
        messageTypeFilter(newVal) {
            localStorage.setItem('messageTypeFilter', newVal);
        }
    }

});

