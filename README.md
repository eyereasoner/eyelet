# EYE as LLM Generated Code to Emulate Thinking

**Abstract**  
- This research presents a novel approach to computational reasoning by using **Large Language Models (LLMs)** such as *GPT 5 Thinking*—to translate **Data** + **Logic** + **Goal / Query** into **self-contained Python programs**.
- This method supports the automated production of **Answer**, **Reason why** and **Check (harness)**, bridging symbolic reasoning paradigms with data-driven generative models.
- This work demonstrates that LLMs can serve not only as text generators but also as **meta-compilers for executable reasoning processes**, emulating certain aspects of structured thought.

---

## Conceptual Overview
```
                 ┌──────────────────────────────────────────────┐
                 │                  LLM input                   │
                 │   • Data (e.g. RDF triples)                  │
                 │   • Logic (e.g. N3 Logic                     │
                 │   • Goal / Query                             │
                 └───────────────────────┬──────────────────────┘
                                         ▼
                 ┌──────────────────────────────────────────────┐
                 │           LLM (e.g. GPT 5 Thinking)          │
                 │   • Translates Data + Logic + Goal           │
                 │   • Synthesizes Python code                  │
                 │   • Constructs proof strategy                │
                 └───────────────────────┬──────────────────────┘
                                         ▼
                 ┌──────────────────────────────────────────────┐
                 │        Self-contained Python Program         │
                 │   • Produces Answer to Goal / Query          │
                 │   • Produces Reason why                      │
                 │   • Runs an independent Check (harness)      │
                 └──────────────────────────────────────────────┘
```
---

## Usage

1. Run [brain](brain) branches of intelligence to get [arc](brain/arc) answer, reason why and check (harness):

   ```bash
   ./test
   ```

