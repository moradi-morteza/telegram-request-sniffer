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
        hideFileUploads: false,
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

            const requestView = document.getElementById("requestView");
            const responseView = document.getElementById("responseView");
            requestView.innerHTML = "";
            responseView.innerHTML = "";

            if (type === "RESPONSE" || type === "ERROR") {
                // Left: correlated request, Right: this response/error
                let requestJson = this.messages.find(item => item.TOKEN === token && item.TYPE === "REQUEST");
                if (requestJson) {
                    const editor = new JSONEditor(requestView);
                    editor.set(requestJson);
                    this.requestJsonContainer = requestJson;
                }
                const editor = new JSONEditor(responseView);
                editor.set(jsonObject);
                this.responseJsonContainer = jsonObject;
            } else {
                // Left: clicked item (REQUEST / SERVER), Right: correlated response/error if any
                const editor = new JSONEditor(requestView);
                editor.set(jsonObject);
                this.requestJsonContainer = jsonObject;

                let responseJsons = this.messages.filter(item => item.TOKEN === token && (item.TYPE === "RESPONSE" || item.TYPE === "ERROR"));
                this.responseJsonContainer = responseJsons;
                responseJsons.forEach(responseJson => {
                    const responseViewEditor = new JSONEditor(responseView);
                    responseViewEditor.set(responseJson);
                });
            }

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
        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const urlLocal = `${protocol}//${window.location.host}/ws`;
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
        this.hideFileUploads = localStorage.getItem('hideFileUploads') === 'true';
    },
    computed: {
        filteredData() {

            let filteredMessages = this.messages;

            if (this.messageTypeFilter !== 'all') {
                filteredMessages = filteredMessages.filter(
                    message => message.TYPE === this.messageTypeFilter
                );
            }

            if (this.hideFileUploads) {
                filteredMessages = filteredMessages.filter(
                    message => message.CLASS_NAME !== 'TL_upload_getFile' && message.CLASS_NAME !== 'TL_upload_file'
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
        },
        hideFileUploads(newVal) {
            localStorage.setItem('hideFileUploads', newVal);
        }
    }

});

