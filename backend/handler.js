import {
  DynamoDBClient,
  ScanCommand,
  PutItemCommand,
  UpdateItemCommand,
  DeleteItemCommand,
} from '@aws-sdk/client-dynamodb';
import { marshall, unmarshall } from '@aws-sdk/util-dynamodb';
import { randomUUID } from 'crypto';

const client = new DynamoDBClient({});
const TABLE_NAME = process.env.TABLE;

const headers = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Credentials": true,
};

export const api = async (event) => {
  const { body, pathParameters } = event;
  const { method: httpMethod, path } = event.requestContext.http;

  if (httpMethod === 'GET' && path === '/reviews') {
    const { Items } = await client.send(new ScanCommand({ TableName: TABLE_NAME }));
    const reviews = Items.map(item => unmarshall(item));
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(reviews),
    };
  }

  if (httpMethod === 'POST' && path === '/reviews') {
    const review = JSON.parse(body);
    review.id = randomUUID();
    await client.send(new PutItemCommand({
      TableName: TABLE_NAME,
      Item: marshall(review),
    }));
    return {
      statusCode: 201,
      headers,
      body: JSON.stringify(review),
    };
  }

  if (httpMethod === 'PUT' && path.startsWith('/reviews/')) {
    const { id } = pathParameters;
    const reviewUpdates = JSON.parse(body);
    
    const updateExpression = 'SET ' + Object.keys(reviewUpdates).map(key => `#${key} = :${key}`).join(', ');
    const expressionAttributeNames = {};
    const expressionAttributeValues = {};

    for (const key in reviewUpdates) {
      expressionAttributeNames[`#${key}`] = key;
      expressionAttributeValues[`:${key}`] = reviewUpdates[key];
    }

    const { Attributes } = await client.send(new UpdateItemCommand({
      TableName: TABLE_NAME,
      Key: marshall({ id }),
      UpdateExpression: updateExpression,
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: marshall(expressionAttributeValues),
      ReturnValues: 'ALL_NEW',
    }));
    
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(unmarshall(Attributes)),
    };
  }

  if (httpMethod === 'DELETE' && path.startsWith('/reviews/')) {
    const { id } = pathParameters;
    await client.send(new DeleteItemCommand({
      TableName: TABLE_NAME,
      Key: marshall({ id }),
    }));
    return {
      statusCode: 204,
      headers,
      body: '',
    };
  }

  return {
    statusCode: 404,
    headers,
    body: JSON.stringify({ message: 'Not Found' }),
  };
}; 