import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';
import uuid from 'uuid';

// load .env vars
dotenv.config();

// jwt token related functions
export function createToken() {
  const id = uuid.v4();
  const obj = {
    id,
    createdAt: Date.now(),
  };
  return jwt.sign(obj, process.env.APP_SECRET);
}

export function getAuthorizationId(authorization) {
  if (!authorization) {
    return null;
  }

  const token = authorization.replace('Bearer ', '');
  return getUserIdFromToken(token);
}

export function getUserIdFromToken(token) {
  const {
    APP_SECRET
  } = process.env;

  try {
    const { id } = jwt.verify(token, APP_SECRET);
    return id;
  } catch (error) {
    console.log(error);
    return null;
  }
}

// hash functions
export async function createHash(str) {
  return bcrypt.hash(str, 10);
}

export async function compareHashes(password, hash) {
  return bcrypt.compare(password, hash);
}

export async function validatePassword(password) {
  const {
    APP_PASSWORD,
  } = process.env;

  return compareHashes(password, APP_PASSWORD);
}

export function isAuthenticated(context) {
  const { auth } = context;
  if (!auth) {
    return false;
  }

  const { id } = auth;
  return !!id;
}

// general auth functions
export function handleAuth(context) {
  if (!isAuthenticated(context)) {
    throw createAuthError('You must be logged in to query this schema');
  }
}
