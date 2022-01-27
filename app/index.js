const express = require("express")
const path = require("path")
const serveIndex = require("serve-index")
const port = process.env.PORT || 5000

express()
    //Access to static file to simulate exposure of unexpected content (not expected to be deployed)
    .use(express.static(path.join(__dirname, "assets")))
    //Simulate a directory listing enabled on path "/static"
    .use("/static", express.static("resources"), serveIndex("resources", {
        "icons": true
    }))
    //Simulate cookies issuing
    .get("/start", (req, res) => {
        let optionsInsecure = {
            maxAge: 1000 * 60 * 15,
            httpOnly: false,
            sameSite: "None"
        }
        let optionsSecure = {
            maxAge: 1000 * 60 * 15,
            httpOnly: true,
            secure: true,
            sameSite: "Strict"
        }
        res.cookie("Cookie1", "Value1", optionsInsecure)
        res.cookie("Cookie2", "Value2", optionsSecure)
        res.send("Cookies issued")
    })
    //Home
    .get("/", (req, res) => res.send("It works."))
    //Simulate an AXIS2 admin module enabled with default credentials
    .post("/axis2-admin/login", (req, res) => res.send("<h1>Welcome to Axis2 Web Admin Module !!</h1>"))
    //Provide a service to raise an error if the parameter "name" is not provided
    .get("/hello", (req, res) => {
        let x = req.query.name;
        x = x.substring(5);
        res.send("Hello " + x);
    })
    .listen(port, () => console.log(`Listening on ${ port }`))