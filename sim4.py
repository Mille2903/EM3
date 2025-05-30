import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

num_samples = 30
replications = 20  
x = np.arange(num_samples)  


conditions_meningsfuld = [
    {"name": "Pseudoord", "A": 6, "k": 2, "semantik": "meningsfuld"},
    {"name": "Sjælden", "A": 5, "k": 5, "semantik": "meningsfuld"},
    {"name": "Hyppig", "A": 4, "k": 12, "semantik": "meningsfuld"}
]


conditions_nonsens = [
    {"name": "Pseudoord", "mean": 6, "semantik": "nonsens"},  
    {"name": "Sjælden", "mean": 5, "semantik": "nonsens"},  
    {"name": "Hyppig", "mean": 4, "semantik": "nonsens"}  
]


np.random.seed(42)  
dfs = []


for rep in range(replications):
    for cond in conditions_meningsfuld:
        A, k, name, semantik = cond["A"], cond["k"], cond["name"], cond["semantik"]
        y_clean = A * np.exp(-k * x / num_samples)
        noise = np.random.normal(0, 1, num_samples)  
        y_noisy = y_clean + noise
        dfs.append(pd.DataFrame({
            "Condition": name,
            "Tid": x,
            "Value_Clean": y_clean,
            "Value_Noisy": y_noisy,
            "Semantik": semantik,
            "Replication": rep + 1  
        }))

    
    for cond in conditions_nonsens:
        name, mean, semantik = cond["name"], cond["mean"], cond["semantik"]
        y_clean = np.zeros(num_samples)  
        y_noisy = np.random.normal(mean, 1, num_samples)  
        dfs.append(pd.DataFrame({
            "Condition": name,
            "Tid": x,
            "Value_Clean": y_clean,
            "Value_Noisy": y_noisy,
            "Semantik": semantik,
            "Replication": rep + 1
        }))


df = pd.concat(dfs, ignore_index=True)

plt.figure(figsize=(12, 6))
for name, group in df[df["Semantik"] == "meningsfuld"].groupby("Condition"):
    plt.scatter(group["Tid"], group["Value_Noisy"], 
                label=f"{name} (støj, n={replications})", 
                alpha=0.3)  
    plt.plot(x, group["Value_Clean"].iloc[:num_samples],  
             label=f"{name} (ren)", linestyle='--')

plt.xlabel("Tid (Samplenummer)")
plt.ylabel("max-amplitude (mikroVolt)")
plt.title(f"Eksponentielt aftagende respons (M+) – {replications} gentagelser")
plt.legend()
plt.grid(True)
plt.xlim(0, 29)
plt.show()

df.to_csv("halløj_replicated.csv", index=False)

print(df.head())
print(f"\nTotal rows: {len(df)} (Expected: {num_samples * (len(conditions_meningsfuld) + len(conditions_nonsens)) * replications})")