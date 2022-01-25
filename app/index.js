const express = require("express")
const path = require("path")
const port = process.env.PORT || 5000

express()
    .use(express.static(path.join(__dirname, "assets")))
    .get("/", (req, res) => res.send("It works."))
    .post("/axis2-admin/login", (req, res) => res.send("<h1>Welcome to Axis2 Web Admin Module !!</h1>"))
    .get("/hello", (req, res) => {
        let x = req.query.name;
        x = x.substring(5);
        res.send("Hello " + x);
    })
    .listen(port, () => console.log(`Listening on ${ port }`))