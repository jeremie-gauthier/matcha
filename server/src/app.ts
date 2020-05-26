import express, { Request, Response, NextFunction } from "express";
import { ServerError } from "./typings";

const app = express();

// catch 404 and forward to error handler
app.use((req: Request, res: Response, next: NextFunction) => {
	const err = new ServerError("Route Not Found", 404);
	return next(err);
});

// handle errors
app.use((err: ServerError, req: Request, res: Response) => {
	return res.status(err.status ?? 500).json({
		message: err.status ? err.message : "An error occured.",
	});
});

export default app;
