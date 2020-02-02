'use strict';

import AWS from 'aws-sdk';

const baseResponse = {
  statusCode: 200,
  headers: {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin' : '*', // Required for CORS support to work
    'Access-Control-Allow-Credentials' : true // Required for cookies, authorization headers with HTTPS
  },
  body: undefined,
};

const { APP_EMAIL } = process.env;

exports.rest = async function (event, _, callback) {
  let response;
  let body;
  let fail = false;

  console.log(event.body);
  const { name: rawName, email, message } = JSON.parse(event.body);

  // do validation here
  if (!email.match(/^[^@]+@[^@]+$/)) {
    console.log('Not sending: invalid email address', event);
    fail = true;
  }
  
  // check and validate name
  const name = rawName.substr(0, 40).replace(/[^\w\s]/g, '');
  
  // stop here if failed
  if (fail) {
    body = {
      send: false,
      data: null,
    };

    response = {
      ...baseResponse,
      body: JSON.stringify(body),
    };
  }

  const htmlBody = `
    <!DOCTYPE html>
    <html>
      <head>
      </head>
      <body>
      <p>Message from: ${name}</p>
      <p>Email: ${email}</>
      <p>Message <br />${message}</p>
      </body>
    </html>
  `;

  const textBody = `
    Message from ${name},
    ...
    Email: ${email}
    Message: \n ${message}
  `;

  // Create sendEmail params
  const params = {
    Destination: {
      ToAddresses: [APP_EMAIL],
    },
    ReplyToAddresses: [email],
    Message: {
      Body: {
        Html: {
          Charset: "UTF-8",
          Data: htmlBody,
        },
        Text: {
          Charset: "UTF-8",
          Data: textBody,
        },
      },
      Subject: {
        Charset: "UTF-8",
        Data: `New Message from ${name}!`,
      },
    },
    Source: `andreasgasser.com <${APP_EMAIL}>`,
  };

  try {
    // send email
    const data = await new AWS.SES({ apiVersion: "2010-12-01" })
      .sendEmail(params)
      .promise();

    // update body with success state
    body = {
      send: true,
      data: data.MessageId,
    };
    
  } catch (error) {
    console.error(error, error.stack);

    // update body with error state
    body = {
      send: false,
      data: null,
    };
  }

  response = {
    ...baseResponse,
    body: JSON.stringify(body),
  };

  // return callback
  callback(null, response);
};
