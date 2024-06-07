export default function SystemInfo() {
  const sandboxID = process.env.CSB_SANDBOX_ID;

  return <p>Sandbox ID:{sandboxID}</p>;
}
