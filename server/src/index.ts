import app from "./app";

const port = process.env.PORT ?? 5000;
const host = process.env.HOST ?? "localhost";
const env = process.env.NODE_ENV ?? "development";

const server = app.listen(port, () => {
	console.info(`Listening on ${host}:${port} in ${env} mode`);
});

export default server;
