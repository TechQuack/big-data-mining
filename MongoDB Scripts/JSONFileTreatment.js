db.BIOC.aggregate([
    {
        $unwind: "$passages"
    },
    {
        $match: {
            "passages.infons.section_type":  {$in: ["TITLE", "ABSTRACT"]}
        }
    },
    {
        $project: {
            pmid: 1,
            data: {
                text: "$passages.text",
                isTitle: {
                    $cond: {
                        "if": {$eq: ["$passages.infons.section_type", "TITLE"]},
                        "then": true,
                        "else": false
                    }
                },
                isResume: {
                    $cond: {
                        "if": {$eq: ["$passages.infons.section_type", "ABSTRACT"]},
                        "then": true,
                        "else": false
                    }
                },
            },

            _id: 0
        }
    },
    {
        $group: {
            _id: "$pmid",
            title:
             {$push: {$cond: {
                "if": {$eq: [true, "$data.isTitle"]},
                "then": "$data.text",
                "else": null
            }}},
            resume: {$push: {$cond: {
                "if": {$eq: [true, "$data.isResume"]},
                "then": "$data.text",
                "else": null
            }}},
        }
    },
    {
        $project: {
            resume: {$filter: {
                input: "$resume",
                as: "element",
                cond: {$ne: ["$$element", null]}
            }},
            title: {$first: {$filter: {
                input: "$title",
                as: "element",
                cond: {$ne: ["$$element", null]}
            }}}
        }
    },
    {
        $project: {
            resume: {
                $reduce: {
                    input: "$resume",
                    initialValue: "",
                    in: {$concat: ["$$value", " ", "$$this"]}
                }
            },
            title: 1
        }
    },
    {
        $project: {
            result: {$concat: [{$toString: "$_id"}, "/", "$title", " ", "$resume"]},
            _id: 0
        }
    }
])