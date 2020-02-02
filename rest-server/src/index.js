'use strict';

// import bcrypt from 'bcryptjs';
import { validatePassword, createToken } from './auth';

exports.rest = async function (event, _, callback) {
    const { body } = event;
    console.log(body);
    const { password } = JSON.parse(body);

    // only enable if new password is needed
    // const hash = await bcrypt.hash(password, 10);
    // console.log(hash);

    // const valid = await validatePassword(password);
    // const token = valid ? createToken() : '';

    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Access-Control-Allow-Origin' : '*', // Required for CORS support to work
            'Access-Control-Allow-Credentials' : true // Required for cookies, authorization headers with HTTPS
        },
        // body: JSON.stringify({
        //     valid,
        //     token,
        // }),
        // body: JSON.stringify(body),
        body,
    };
    callback(null, response);
};
