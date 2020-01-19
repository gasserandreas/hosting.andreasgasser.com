'use strict';

exports.handler = function (event, context, callback) {
    console.log(event);
    console.log(context);

    const { body } = event;
    console.log(body.data);

    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/html; charset=utf-8',
        },
        body: body,
    };
    callback(null, response);
};
