1. Task code design 
When you write a new environment (task), each task directory should look like 

```
task 
    agents/
        rsl_rl_ppo_cfg.py
        compositional_rsl_rl_cfg.py
    env_cfg/
        action_cfg.py
        commands_cfg.py 
        curriculum_cfg.py
        event_cfg.py
        observation_cfg.py
        physics_cfg.py
        reward_cfg.py
        scene_cfg.py
        ....
    mdp/
        reward.py
        observation.py
        ...
    util/ (if any)
    __init__.py
    *_env_cfg.py
    *_env.py (if any)
    README.md
```

2. Make config files standalone 
Avoid inheriting term and env config from another task as this makes task files messy. 

3. MDP
If you can reuse mdp functions from another task, you can reuse them.

4. Term configuration owns task-specific constants
Define task-specific joint lists, body selections, ranges, and other constants in the
owning term configuration under `env_cfg/`, not in `mdp/` modules. For example,
define `LOWER_JOINTS` and `UPPER_JOINTS` in `env_cfg/action_cfg.py`; other term
configuration files in the same task may import them from there. Do not create
`mdp/joints.py` or similar constant-only MDP modules. Reusable MDP functions and
classes must receive task-specific values through term configuration parameters.
