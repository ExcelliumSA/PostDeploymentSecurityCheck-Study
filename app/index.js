const express = require("express")
const path = require("path")
const port = process.env.PORT || 5000

express()
    .use(express.static(path.join(__dirname, "assets")))
    .get("/", (req, res) => res.send("It works."))
    .get("/hello", (req, res) => {
        let x = req.query.name;
        x = x.substring(5);
        res.send("Hello " + x);
    })
    .listen(port, () => console.log(`Listening on ${ port }`))