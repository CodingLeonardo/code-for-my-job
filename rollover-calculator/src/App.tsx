import { useState, useEffect } from "react";

import "./App.css";

function App() {
  const [deposit, setDeposit] = useState(0);
  const [bonusPercent, setBonusPercent] = useState(0);
  const [rollover, setRollover] = useState(0);

  const bonusDecimal = bonusPercent / 100;
  const bonusReceived = deposit * bonusDecimal;
  const goal = (deposit + bonusReceived) * rollover;

  useEffect(() => {
    if (deposit > 0 && rollover > 0 && bonusPercent > 0) {
      if ("clipboard" in navigator) {
        navigator.clipboard
          .writeText(
            goal.toLocaleString("es-ve", {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
            })
          )
          .then(() => console.log("Text copied to clipboard"))
          .catch((error) =>
            console.error("Error copying text to clipboard:", error)
          );
      } else {
        console.error("`useClipboard`: Navigation Clipboard is not supported");
      }
    }
  }, [deposit, bonusPercent, rollover]);

  const handleDepositChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    // Allow only numbers and a single decimal point
    if (/^\d*\.?\d*$/.test(value)) {
      setDeposit(Number(value));
    }
  };

  return (
    <div className="min-h-screen bg-neutral-900 flex items-center justify-center flex-col py-4 px-1 font-sans">
      <form className="space-y-5">
        <div>
          <label
            className="block text-sm font-medium text-neutral-200 mb-1"
            htmlFor="deposit"
          >
            Depósito
          </label>
          <input
            id="deposit"
            type="number"
            value={deposit === 0 ? "" : deposit}
            onChange={handleDepositChange}
            placeholder="Ej: 1000"
            className="w-full rounded-lg border border-neutral-800 bg-neutral-800 text-neutral-100 focus:border-yellow-500 focus:ring-2 focus:ring-yellow-200 px-4 py-2 text-lg transition outline-none placeholder:text-neutral-500"
          />
        </div>
        <div>
          <label
            className="block text-sm font-medium text-neutral-200 mb-1"
            htmlFor="bonus"
          >
            % de bono
          </label>
          <input
            id="bonus"
            type="number"
            value={bonusPercent === 0 ? "" : bonusPercent}
            onChange={(e) => setBonusPercent(Number(e.target.value))}
            placeholder="Ej: 50"
            className="w-full rounded-lg border border-neutral-800 bg-neutral-800 text-neutral-100 focus:border-yellow-500 focus:ring-2 focus:ring-yellow-200 px-4 py-2 text-lg transition outline-none placeholder:text-neutral-500"
          />
        </div>
        <div>
          <label
            className="block text-sm font-medium text-neutral-200 mb-1"
            htmlFor="rollover"
          >
            Rollover
          </label>
          <input
            id="rollover"
            type="number"
            value={rollover === 0 ? "" : rollover}
            onChange={(e) => setRollover(Number(e.target.value))}
            placeholder="Ej: 21"
            className="w-full rounded-lg border border-neutral-800 bg-neutral-800 text-neutral-100 focus:border-yellow-500 focus:ring-2 focus:ring-yellow-200 px-4 py-2 text-lg transition outline-none placeholder:text-neutral-500"
          />
        </div>
        <div>
          <label
            className="block text-sm font-medium text-neutral-200 mb-1"
            htmlFor="bonus-received"
          >
            Bono recibido
          </label>
          <input
            id="bonus-received"
            type="number"
            min="0"
            max="100"
            value={bonusReceived}
            readOnly
            className="w-full rounded-lg border border-neutral-800 bg-neutral-800 text-neutral-100 focus:border-yellow-500 focus:ring-2 focus:ring-yellow-200 px-4 py-2 text-lg transition outline-none placeholder:text-neutral-500"
          />
        </div>
      </form>
      <div className="mt-8 bg-neutral-800 rounded-xl shadow-inner p-6 flex flex-col items-center border border-neutral-700">
        <h2 className="text-lg font-semibold text-neutral-100 mb-2">
          Meta de Retiro
        </h2>
        <div className="text-3xl font-bold text-yellow-400 mb-1">
          {isNaN(goal)
            ? "--"
            : goal.toLocaleString("es-ve", {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              })}
        </div>
        <p className="text-xs text-neutral-400 mt-2">
          <span className="font-medium">Fórmula:</span> (Depósito + % Bono) ×
          Rollover
        </p>
      </div>
    </div>
  );
}

export default App;
